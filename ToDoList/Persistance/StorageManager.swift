//
//  StorageManager.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 10.07.2023.
//

import UIKit
import CoreData

public final class CoreDataManager: NSObject {
    override init() {}
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    // Это слепок контейнера из глобальной памяти
    private var contex: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    public func saveTodoItem(todoItem: TodoItem) {
        guard let todoItemEntityDescription = NSEntityDescription.entity(forEntityName: "TodoItemPersiatence", in: contex ) else {return}
        let todoItemPersistence = TodoItemPersiatence(entity: todoItemEntityDescription, insertInto: contex)
        todoItemPersistence.id = todoItem.id
        todoItemPersistence.text = todoItem.text
        todoItemPersistence.importance = todoItem.importance
        todoItemPersistence.done = todoItem.done
        todoItemPersistence.deadline = todoItem.deadline
        todoItemPersistence.dateCreation = todoItem.dateCreation
        todoItemPersistence.dateChanging = todoItem.dateChanging
        contex.save()
    }
}
 
