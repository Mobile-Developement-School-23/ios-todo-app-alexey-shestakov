//
//  NetworkDataFetch.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 06.07.2023.
//

import Foundation

protocol NetworkService {
    func getAllItems() async throws -> [TodoItem]
    func updateItems(toDoItems: [TodoItem]) async throws -> [TodoItem]
    func getItem(TodoItem: TodoItem) async throws
    func removeItem(TodoItem: TodoItem) async throws
    func changeItem(TodoItem: TodoItem) async throws
    func addItem(TodoItem: TodoItem) async throws
}

final class NetworkFetcher: NetworkService {
    private var revision: Int?
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    func getAllItems() async throws -> [TodoItem] {
        let url = try RequestProcessor.makeURL()
        let (data, _) = try await RequestProcessor.performRequest(with: url)
        let networkListToDoItems = try decoder.decode(ListToDoItems.self, from: data)
        revision = networkListToDoItems.revision
//        print(revision)
        return networkListToDoItems.list.map { TodoItem.convert(from: $0) }
    }
    
    func updateItems(toDoItems: [TodoItem]) async throws -> [TodoItem] {
        print("requestUpdateItems")
        let url = try RequestProcessor.makeURL()
        let listToDoItems = ListToDoItems(list: toDoItems.map{$0.networkItem})
        let httpBody = try encoder.encode(listToDoItems)
        let (responseData, _) = try await RequestProcessor.performRequest(with: url, method: .patch, revision: revision ?? 0, httpBody: httpBody)
        let toDoItemNetwork = try decoder.decode(ListToDoItems.self, from: responseData)
        print(toDoItemNetwork)
        revision = toDoItemNetwork.revision
        return toDoItemNetwork.list.map{TodoItem.convert(from: $0)}
    }
    
    func getItem(TodoItem: TodoItem) async throws {
        print("requestGetItem")
        let url = try RequestProcessor.makeURL(from: TodoItem.id)
        let (data, _) = try await RequestProcessor.performRequest(with: url)
        let toDoItemNetwork = try decoder.decode(ElementToDoItem.self, from: data)
        print(toDoItemNetwork)
        revision = toDoItemNetwork.revision
    }
    
    func removeItem(TodoItem: TodoItem) async throws {
        print("requestRemoveItem")
        let url = try RequestProcessor.makeURL(from: TodoItem.id)
        let (data, _) = try await RequestProcessor.performRequest(with: url, method: .delete, revision: revision)
        let toDoItemNetwork = try decoder.decode(ElementToDoItem.self, from: data)
        print(toDoItemNetwork)
        revision = toDoItemNetwork.revision
    }
    
    func changeItem(TodoItem: TodoItem) async throws {
        let url = try RequestProcessor.makeURL(from: TodoItem.id)
        let elementToDoItem = ElementToDoItem(element: TodoItem.networkItem)
        let httpBody = try encoder.encode(elementToDoItem)
        let (responseData, _) = try await RequestProcessor.performRequest(with: url, method: .put, revision: revision, httpBody: httpBody)
        let toDoItemNetwork = try decoder.decode(ElementToDoItem.self, from: responseData)
        revision = toDoItemNetwork.revision
    }
    
    func addItem(TodoItem: TodoItem) async throws {
//        print(revision)
        let elementToDoItem = ElementToDoItem(element: TodoItem.networkItem)
        let url = try RequestProcessor.makeURL()
        let httpBody = try encoder.encode(elementToDoItem)
//        print(String(data: httpBody, encoding: .utf8))
        let (responseData, _) = try await RequestProcessor.performRequest(with: url, method: .post, revision: revision, httpBody: httpBody)
        let toDoItemNetwork = try decoder.decode(ElementToDoItem.self, from: responseData)
        revision = toDoItemNetwork.revision
    }
    
    
}
