//
//  NetworkDataFetch.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 06.07.2023.
//

import Foundation

protocol NetworkService {
    func getAllItems() async throws -> [TodoItem]
    func updateItems(toDoItems: [TodoItem]) async throws
    func getItem(todoItem: TodoItem) async throws
    func removeItem(todoItem: TodoItem) async throws
    func changeItem(todoItem: TodoItem) async throws
    func addItem(todoItem: TodoItem) async throws
}

final class NetworkFetcher: NetworkService {
    private var revision: Int?
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    let lock = NSLock()
    
    private func getDelay(with retryCount: Int) -> UInt64 {
        let maxDelay = 120.0
        let minDelay = 2.0
        var delay = retryCount == 0 ? minDelay : minDelay * Double(retryCount)
        let factor = 1.5
        let jitter = 0.05
        delay = retryCount == 0 ? minDelay : delay * factor
        
        let shift = Double.random(in: -(delay * jitter) ... delay * jitter)
        print(delay + shift)
        return UInt64(min(delay + shift, maxDelay) * 1_000_000_000)
    }

    func getAllItems() async throws -> [TodoItem] {
        let url = try RequestProcessor.makeURL()
        let (data, _) = try await RequestProcessor.performRequest(with: url)
        
        let networkListToDoItems = try decoder.decode(ListToDoItems.self, from: data)
        lock.withLock {
            revision = networkListToDoItems.revision
        }
        return networkListToDoItems.list.map { TodoItem.convert(from: $0) }
    }
    
    func getAllItems(maxRetryAttempts: Int) async throws -> [TodoItem] {
        print("getAllItems(with retry: Int)")
        var retryCount = 0
        while retryCount < maxRetryAttempts {
            do {
                return try await getAllItems()
            } catch {
                try await Task.sleep(nanoseconds: getDelay(with: retryCount))
                retryCount += 1
            }
        }
        throw Errors.noResponse
    }
    
    func updateItems(toDoItems: [TodoItem]) async throws {
        print("updateItems")
        let url = try RequestProcessor.makeURL()
        let listToDoItems = ListToDoItems(list: toDoItems.map{$0.networkItem})
        let httpBody = try encoder.encode(listToDoItems)
        let (responseData, _) = try await RequestProcessor.performRequest(with: url, method: .patch, revision: revision ?? 0, httpBody: httpBody)
        let toDoItemNetwork = try decoder.decode(ListToDoItems.self, from: responseData)
        lock.withLock {
            revision = toDoItemNetwork.revision
        }
    }
    
    func updateItems(toDoItems: [TodoItem], maxRetryAttempts: Int) async throws {
        print("updateItems(with retry: Int)")
        var retryCount = 0
        while retryCount < maxRetryAttempts {
            do {
                try await updateItems(toDoItems: toDoItems)
                return
            } catch {
                try await Task.sleep(nanoseconds: getDelay(with: retryCount))
                retryCount += 1
            }
        }
        throw Errors.noResponse
    }
    
    func getItem(todoItem: TodoItem) async throws {
        print("getItem")
        let url = try RequestProcessor.makeURL(from: todoItem.id)
        let (data, _) = try await RequestProcessor.performRequest(with: url)
        let toDoItemNetwork = try decoder.decode(ElementToDoItem.self, from: data)
        print(toDoItemNetwork)
        revision = toDoItemNetwork.revision
    }
    
    func removeItem(todoItem: TodoItem) async throws {
        print("removeItem")
        let url = try RequestProcessor.makeURL(from: todoItem.id)
        let (data, _) = try await RequestProcessor.performRequest(with: url, method: .delete, revision: revision)
        let toDoItemNetwork = try decoder.decode(ElementToDoItem.self, from: data)
        print(toDoItemNetwork)
        lock.withLock {
            revision = toDoItemNetwork.revision
        }
    }
    
    func removeItem(toDoItems: TodoItem, maxRetryAttempts: Int) async throws {
        print("removeItem(with retry: Int)")
        var retryCount = 0
        while retryCount < maxRetryAttempts {
            do {
                return try await removeItem(todoItem: toDoItems)
            } catch {
                try await Task.sleep(nanoseconds: getDelay(with: retryCount))
                retryCount += 1
            }
        }
        throw Errors.noResponse
    }
    
    func changeItem(todoItem: TodoItem) async throws {
        let url = try RequestProcessor.makeURL(from: todoItem.id)
        let elementToDoItem = ElementToDoItem(element: todoItem.networkItem)
        let httpBody = try encoder.encode(elementToDoItem)
        let (responseData, _) = try await RequestProcessor.performRequest(with: url, method: .put, revision: revision, httpBody: httpBody)
        let toDoItemNetwork = try decoder.decode(ElementToDoItem.self, from: responseData)
        lock.withLock {
            revision = toDoItemNetwork.revision
        }
    }
    
    func changeItem(toDoItems: TodoItem, maxRetryAttempts: Int) async throws {
        print("changeItem(with retry: Int)")
        var retryCount = 0
        while retryCount < maxRetryAttempts {
            do {
                return try await changeItem(todoItem: toDoItems)
            } catch {
                try await Task.sleep(nanoseconds: getDelay(with: retryCount))
                retryCount += 1
            }
        }
        throw Errors.noResponse
    }
    
    func addItem(todoItem: TodoItem) async throws {
        let elementToDoItem = ElementToDoItem(element: todoItem.networkItem)
        let url = try RequestProcessor.makeURL()
        let httpBody = try encoder.encode(elementToDoItem)
        let (responseData, _) = try await RequestProcessor.performRequest(with: url, method: .post, revision: revision, httpBody: httpBody)
        let toDoItemNetwork = try decoder.decode(ElementToDoItem.self, from: responseData)
        lock.withLock {
            revision = toDoItemNetwork.revision
        }
    }
    
    func addItem(toDoItems: TodoItem, maxRetryAttempts: Int) async throws {
        print("addItem(with retry: Int)")
        var retryCount = 0
        while retryCount < maxRetryAttempts {
            do {
                return try await addItem(todoItem: toDoItems)
            } catch {
                try await Task.sleep(nanoseconds: getDelay(with: retryCount))
                retryCount += 1
            }
        }
        throw Errors.noResponse
    }
    
    enum Errors: Error {
        case noResponse
    }
}
