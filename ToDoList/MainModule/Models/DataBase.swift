//
//  DataBase.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//

import Foundation

class DataBase {
    
    private let cache = FileCache()
    private let networkFetcher = NetworkFetcher()
    
    private let userDef = UserDefaults.standard
    private let userDefKey = "isDirty"
    
    var mainViewModelDelegate: MainViewModel?
    
    var toDoList = [TodoItem]()
    
    var typeSorting: SortedBy = .none
    
    var operationTaskChange: Task<Void, Never>?
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
        Task {
            do {
                let cachArray = Array(self.cache.items.values)
                try await networkFetcher.updateItems(toDoItems: cachArray, maxRetryAttempts: numberRetries)
                userDef.set(false, forKey: userDefKey)
            } catch {
                print(error)
            }
        }
    }
    
    public func saveTask(item: TodoItem, new: Bool) {
        cache.add(item: item)
        countDone()
        try? self.cache.saveToJson(toFileWithID: fileName)
        print((cache.items.values).map{$0.done})
        guard userDef.bool(forKey: userDefKey) != true else {
            updateTasks()
            return
        }
        if let operationTaskChange,
           !operationTaskChange.isCancelled {
            operationTaskChange.cancel()
        }
        let currentTask = Task {
            do {
                if new {
                    try await networkFetcher.addItem(toDoItems: item, maxRetryAttempts: numberRetries)
                } else {
                    try await networkFetcher.changeItem(toDoItems: item, maxRetryAttempts: numberRetries)
                }
            } catch {
                userDef.set(true, forKey: userDefKey)
                print(userDef.bool(forKey: userDefKey), "UserDef")
            }
        }
        operationTaskChange = currentTask
    }
    
    public func removeTask(id: String, todoItem: TodoItem) {
        cache.remove(id: id)
        countDone()
        try? self.cache.saveToJson(toFileWithID: fileName)
        guard userDef.bool(forKey: userDefKey) != true else {
            updateTasks()
            return
        }
        Task {
            do {
                try await networkFetcher.removeItem(toDoItems: todoItem, maxRetryAttempts: numberRetries)
            } catch {
                userDef.set(true, forKey: userDefKey)
                print(userDef.bool(forKey: userDefKey), "UserDef")
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
        /// Если это первый запуск прилы, то создаем дирректорию и получаем данные с сервера
        let userDefailts = UserDefaults.standard
        if userDefailts.bool(forKey: "DirectoryExists") == false {
            try? self.cache.saveToJson(toFileWithID: fileName)
            userDefailts.set(true, forKey: "DirectoryExists")
        }
        if userDefailts.bool(forKey: userDefKey) == false {
            Task {
                await self.loadFromServer()
                await MainActor.run {
                    try? self.cache.loadFromJson(from: fileName)
                    toDoList = Array(self.cache.items.values)
                    toDoList.sort{$0.dateCreation > $1.dateCreation}
                    mainViewModelDelegate?.loadFromServer.value = true
                    mainViewModelDelegate?.numberDoneTasks.value = countDone()
                }
            }
        } else {
            try? self.cache.loadFromJson(from: fileName)
            toDoList = Array(self.cache.items.values)
            toDoList.sort{$0.dateCreation > $1.dateCreation}
            updateTasks()
        }
    }
    
    public func loadFromServer() async {
        do {
            let networkingList = try await networkFetcher.getAllItems(maxRetryAttempts: numberRetries)
            print(networkingList.map{$0.done})
            for toDoItem in networkingList {
                cache.add(item: toDoItem)
            }
            try? cache.saveToJson(toFileWithID: fileName)
        } catch {
            userDef.set(true, forKey: userDefKey)
        }
    }
}


enum SortedBy: String {
    case onlyNotDone = "Несделанные"
    case none = "Все"
    case onlyImportantAndNotDone = "Важные и несделанные"
}

let fileName = "myTasksJson"
let numberRetries = 5
