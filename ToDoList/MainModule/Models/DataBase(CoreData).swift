//
//  DataBase(CoreData).swift
//  ToDoList
//
//  Created by Alexey Shestakov on 13.07.2023.
//

import Foundation
import UIKit

class DataBase {
    private let cache = DataCache(context:
                                    (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext )
    private let networkFetcher = NetworkFetcher()
    
    private let userDef = UserDefaults.standard
    private let userDefKey = "isDirty"
    
    var mainViewModelDelegate: MainViewModel?
    
    var toDoList = [TodoItem]()
    
    var typeSorting: SortedBy = .none
    
    var operationTaskUpdate: Task<Void, Never>?
    
    init() {
        checkDirectoryAndLoad()
    }
    
    public func filterArray() {
        switch typeSorting {
        case .onlyImportantAndNotDone:
            toDoList = Array(self.cache.items.values).filter {$0.importance == .important}.filter {$0.done != true}
        case .onlyNotDone:
            toDoList = Array(self.cache.items.values).filter {$0.done != true}
        case .none:
            toDoList = Array(self.cache.items.values)
        }
        toDoList.sort{$0.dateCreation > $1.dateCreation}
    }
    
    private func updateTasks() {
        if let operationTaskUpdate,
           !operationTaskUpdate.isCancelled {
            operationTaskUpdate.cancel()
        }

        let currentTask = Task { @MainActor in
            do {
                let cachArray = Array(self.cache.items.values)
                mainViewModelDelegate?.changeRequestStatus(operation: .update, statusCompleted: false)
                try await networkFetcher.updateItems(toDoItems: cachArray, maxRetryAttempts: numberRetries)
                mainViewModelDelegate?.changeRequestStatus(operation: .update, statusCompleted: true)
                userDef.set(false, forKey: userDefKey)
            } catch {
                mainViewModelDelegate?.changeRequestStatus(operation: .update, statusCompleted: true)
                print(error)
            }
        }
        operationTaskUpdate = currentTask
    }
    
    public func saveTask(item: TodoItem, new: Bool) {
        if new {
            cache.insert(item: item)
        } else {
            cache.update(item: item)
        }
        countDone()
        guard userDef.bool(forKey: userDefKey) != true else {
            updateTasks()
            return
        }
        Task { @MainActor in
            do {
                if new {
                    mainViewModelDelegate?.changeRequestStatus(operation: .change, statusCompleted: false)
                    try await networkFetcher.addItem(toDoItems: item, maxRetryAttempts: numberRetries)
                    mainViewModelDelegate?.changeRequestStatus(operation: .change, statusCompleted: true)
                } else {
                    mainViewModelDelegate?.changeRequestStatus(operation: .change, statusCompleted: false)
                    try await networkFetcher.changeItem(toDoItems: item, maxRetryAttempts: numberRetries)
                    mainViewModelDelegate?.changeRequestStatus(operation: .change, statusCompleted: true)
                }
            } catch {
                userDef.set(true, forKey: userDefKey)
                mainViewModelDelegate?.changeRequestStatus(operation: .change, statusCompleted: true)
                print("UserDefaults changed in:", userDef.bool(forKey: userDefKey))
            }
        }
    }
    
    public func removeTask(id: String, todoItem: TodoItem) {
        cache.delete(id: id)
        countDone()
        guard userDef.bool(forKey: userDefKey) != true else {
            updateTasks()
            return
        }
        Task {
            do {
                try await networkFetcher.removeItem(toDoItems: todoItem, maxRetryAttempts: numberRetries)
            } catch {
                userDef.set(true, forKey: userDefKey)
                print("UserDefaults changed in:", userDef.bool(forKey: userDefKey))
            }
        }
    }
    
    @discardableResult
    public func countDone() -> Int {
        let array = cache.items.values.filter {$0.done == true}
        mainViewModelDelegate?.numberDoneTasks.value = array.count
        return array.count
    }
    
    private func checkDirectoryAndLoad() {
        let userDefailts = UserDefaults.standard
        cache.loadFromCoreData()
        if userDefailts.bool(forKey: userDefKey) == false {
            Task { @MainActor in
                await self.loadFromServer()
                tasksExtractor()
                mainViewModelDelegate?.changeRequestStatus(operation: .load, statusCompleted: true)
                mainViewModelDelegate?.numberDoneTasks.value = countDone()
            }
        } else {
            tasksExtractor()
            updateTasks()
        }
    }
    
    private func tasksExtractor() {
        toDoList = Array(self.cache.items.values)
        toDoList.sort{$0.dateCreation > $1.dateCreation}
    }
    
    public func loadFromServer() async {
        do {
            let networkingList = try await networkFetcher.getAllItems(maxRetryAttempts: numberRetries)
            print(networkingList.map{$0.text})
            for toDoItem in networkingList {
                if cache.items[toDoItem.id] == nil {
                    cache.insert(item: toDoItem)
                }
            }
            print(cache.items.count)
        } catch {
            userDef.set(true, forKey: userDefKey)
            print("UserDefaults changed in:", userDef.bool(forKey: userDefKey))
        }
    }
}
enum TypeNetworkOperation {
    case change
    case load
    case add
    case delete
    case update
}

enum SortedBy: String {
    case onlyNotDone = "Несделанные"
    case none = "Все"
    case onlyImportantAndNotDone = "Важные и несделанные"
}

let fileName = "myTasksJson"
let numberRetries = 3
