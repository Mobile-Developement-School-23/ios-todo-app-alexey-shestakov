//
//  ListViewModel.swift
//  ToDoList-SwiftUI
//
//  Created by Alexey Shestakov on 19.07.2023.
//

import Foundation

class ListViewModel: ObservableObject {
    private let cache = FileCache()
    
    @Published var _items: [TodoItem] = []
    
    var typeSorting: SortedBy = .none
    
    var items: [TodoItem] {
        get {
            var array: [TodoItem]
            switch typeSorting {
            case .onlyNotDone:
                array = Array(self.cache.items.values).filter {$0.done != true}
            case .none:
                array = Array(self.cache.items.values)
            }
            return array.sorted{$0.dateCreation > $1.dateCreation}
        }
        set {
            _items = newValue
        }
    }
    
    init() {
        getItems()
    }
    
    func filterArray(typeSorting: SortedBy) {
        self.typeSorting = typeSorting
    }
    
    func getItems() {
        try? cache.loadFromJson(from: fileName)
        items = Array(cache.items.values)
    }
    
    func countDone() -> Int {
        let array = Array(self.cache.items.values).filter {$0.done == true}
        return array.count
    }
    
    func deleteItem(todoItem: TodoItem?, index: Int?) {
        guard let todoItem, let index else {return}
        items.remove(at: index)
        cache.remove(id: todoItem.id)
        try? cache.saveToJson(toFileWithID: fileName)
    }
    
    func moveItem(from: IndexSet, to: Int) {
        items.move(fromOffsets: from, toOffset: to)
    }
    
    func addItem(todoItem: TodoItem) {
        items.append(todoItem)
        cache.add(item: todoItem)
        try? self.cache.saveToJson(toFileWithID: fileName)
    }
    
    func updateItem(todoItem: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == todoItem.id }) {
            items[index] = todoItem
        }
        cache.add(item: todoItem)
        try? self.cache.saveToJson(toFileWithID: fileName)
    }
    
    func makeDoneUndone(todoItem: TodoItem) {
        let doneItem = todoItem.updateCompletion()
        if let index = items.firstIndex(where: { $0.id == todoItem.id }) {
            items[index] = doneItem
        }
        cache.add(item: doneItem)
        try? self.cache.saveToJson(toFileWithID: fileName)
    }
}

enum SortedBy: String {
    case onlyNotDone = "Несделанные"
    case none = "Все"
}

let fileName = "myTasksJson"
