//
//  StorageManager.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 10.07.2023.
//

import UIKit
import CoreData

public final class DataCache: NSObject {
    
    private var context: NSManagedObjectContext
    
    private let serialQeue = DispatchQueue(label: "serialQeue", qos: .background)
    
    private(set) var items = [String: TodoItem]()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    
    /// LOAD
    public func load() {
        loadTodoItems().forEach{items[$0.id] = $0}
    }
    
    private func loadTodoItems() -> [TodoItem] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItemPersiatence")
        do {
            let todoList = (try context.fetch(fetchRequest) as? [TodoItemPersiatence]) ?? []
            return todoList.map{TodoItem.convertFromPersistent($0)}
        } catch {
            fatalError("Не удалось загрузить TodoItemPersiatence")
        }
    }
    
    
    /// INSERT
    public func insert(item: TodoItem) {
        items[item.id] = item
        serialQeue.async {
            self.insertTodoItem(todoItem: item)
        }
    }
    
    private func insertTodoItem(todoItem: TodoItem) {
        guard let todoItemEntityDescription = NSEntityDescription.entity(forEntityName: "TodoItemPersiatence", in: context ) else {return}
        let _ = TodoItem.convertToPersistent(todoItem: todoItem, entity: todoItemEntityDescription, context: context)
        saveContext()
    }
    
    
    /// UPDATE
    public func update(item: TodoItem) {
        items[item.id] = item
        serialQeue.async {
            self.updateTodoItem(id: item.id, newTodoItem: item)
        }
    }
    
    private func updateTodoItem(id: String, newTodoItem: TodoItem) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItemPersiatence")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            guard let todoItems = try? context.fetch(fetchRequest) as? [TodoItemPersiatence],
                  let todoItemPersistent = todoItems.first else {return}
            todoItemPersistent.text = newTodoItem.text
            todoItemPersistent.importance = newTodoItem.importance
            todoItemPersistent.done = newTodoItem.done
            todoItemPersistent.deadline = newTodoItem.deadline
            todoItemPersistent.dateCreation = newTodoItem.dateCreation
            todoItemPersistent.dateChanging = newTodoItem.dateChanging
        }
        saveContext()
    }
    
    
    /// DELETE
    @discardableResult
    public func delete(id: String) -> TodoItem? {
        let deleted = items[id]
        items[id] = nil
        serialQeue.async {
            self.deleteTodoItem(id: id)
        }
        return deleted
    }
    
    private func deleteTodoItem(id: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItemPersiatence")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            guard let todoItems = try? context.fetch(fetchRequest) as? [TodoItemPersiatence],
                  let todoItem = todoItems.first else {return}
            context.delete(todoItem)
        }
        saveContext()
    }
    
    public func deleteAllTodoItems() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItemPersiatence")
        do {
            let todoItems = try? context.fetch(fetchRequest) as? [TodoItemPersiatence]
            todoItems?.forEach{context.delete($0)}
        }
        saveContext()
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
}

