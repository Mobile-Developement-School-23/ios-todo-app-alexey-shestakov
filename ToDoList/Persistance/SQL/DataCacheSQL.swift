//
//  DataCacheSQL.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 13.07.2023.
//

import Foundation
import SQLite

final class DataCacheSQL {
    
    private(set) var items = [String: TodoItem]()
    
    private let serialQeue = DispatchQueue(label: "serialQeue", qos: .background)
    
    private var db: Connection!
    
    private var todoItems: Table!
    
    private var id: Expression<String>!
    private var text: Expression<String>!
    private var importance: Expression<String>!
    private var deadline: Expression<Int?>!
    private var done: Expression<Bool>!
    private var dateCreation: Expression<Int>!
    private var dateChanging: Expression<Int?>!
    
    init () {
        do {
            let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
            print("SQL DataBase path: \(path)" )
            db = try Connection("\(path)/TodoItems.sqlite3")
            todoItems = Table("TodoItems")
            
            // create instances of each column
            id = Expression<String>("id")
            text = Expression<String>("text")
            importance = Expression<String>("importance")
            deadline = Expression<Int?>("deadline")
            done = Expression<Bool>("done")
            dateCreation = Expression<Int>("dateCreation")
            dateChanging = Expression<Int?>("dateChanging")
            
            if (!UserDefaults.standard.bool(forKey: "is_db_created")) {
                // if not, then create the table
                try db.run(todoItems.create { table in
                    table.column(id, primaryKey: true)
                    table.column(text)
                    table.column(importance)
                    table.column(deadline)
                    table.column(done)
                    table.column(dateCreation)
                    table.column(dateChanging)
                })
                // set the value to true, so it will not attempt to create the table again
                UserDefaults.standard.set(true, forKey: "is_db_created")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// INSERT
    public func insert(item: TodoItem) {
        items[item.id] = item
        serialQeue.async {
            self.insertTodoItem(item: item)
        }
    }
    
    private func insertTodoItem(item: TodoItem) {
        
        var deadlineInt: Int?
        if let deadlineDate = item.deadline {
            deadlineInt = Int(deadlineDate.timeIntervalSince1970)
        }
        
        let dateCreationInt = Int(item.dateCreation.timeIntervalSince1970)
        
        var dateChangingInt: Int?
        if let dateChangingDate = item.deadline {
            dateChangingInt = Int(dateChangingDate.timeIntervalSince1970)
        }
        
        do {
            try db.run(todoItems.insert(
                id <- item.id,
                text <- item.text,
                importance <- item.importance.rawValue,
                deadline <- deadlineInt,
                done <- item.done,
                dateCreation <- dateCreationInt,
                dateChanging <- dateChangingInt))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// LOAD
    public func load() {
        loadTodoItems().forEach{items[$0.id] = $0}
    }
    
    public func loadTodoItems() -> [TodoItem] {
        var resultList = [TodoItem]()
        todoItems = todoItems.order(id.desc)
        do {
            for item in try db.prepare(todoItems) {
                let importanceString = item[importance]
                let deadlineInt = item[deadline]
                let dateCreationInt = item[dateCreation]
                let dateChangingInt = item[dateChanging]
                
                var deadline: Date?
                if let deadlineInt {
                    let timeinterval = TimeInterval(deadlineInt)
                    deadline = Date(timeIntervalSince1970: timeinterval)
                }
                
                var dateChanging: Date?
                if let dateChangingInt {
                    let timeinterval = TimeInterval(dateChangingInt)
                    dateChanging = Date(timeIntervalSince1970: timeinterval)
                }
                
                
                let todoItem = TodoItem(id: item[id],
                                        text: item[text],
                                        importance: Importance(rawValue: importanceString) ?? .normal,
                                        deadline: deadline,
                                        done: item[done],
                                        dateCreation: Date(timeIntervalSince1970: TimeInterval(dateCreationInt)),
                                        dateChanging: dateChanging)
                resultList.append(todoItem)
            }
        } catch {
            print(error.localizedDescription)
        }
        return resultList
    }
    
    
    
    
    /// UPDATE
    public func update(item: TodoItem) {
        items[item.id] = item
        serialQeue.async {
            self.updateTodoItem(idValue: item.id, newTodoItem: item)
        }
    }
    
    private func updateTodoItem(idValue: String, newTodoItem: TodoItem) {
        var deadlineInt: Int?
        if let deadlineDate = newTodoItem.deadline {
            deadlineInt = Int(deadlineDate.timeIntervalSince1970)
        }
        
        let dateCreationInt = Int(newTodoItem.dateCreation.timeIntervalSince1970)
        
        var dateChangingInt: Int?
        if let dateChangingDate = newTodoItem.deadline {
            dateChangingInt = Int(dateChangingDate.timeIntervalSince1970)
        }
        
        do {
            let todoItem = todoItems.filter(id == idValue).limit(1)
            try db.run(todoItem.update(id <- newTodoItem.id,
                                       text <- newTodoItem.text,
                                       importance <- newTodoItem.importance.rawValue,
                                       deadline <- deadlineInt,
                                       done <- newTodoItem.done,
                                       dateCreation <- dateCreationInt,
                                       dateChanging <- dateChangingInt))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func updateUser(idValue: Int64, nameValue: String, emailValue: String, ageValue: Int64) {
        
    }
    
    /// DELETE
    @discardableResult
    public func delete(id: String) -> TodoItem? {
        print(items)
        let deleted = items[id]
        items[id] = nil
        serialQeue.async {
            self.deleteTodoItem(idValue: id)
        }
        return deleted
    }
    
    private func deleteTodoItem(idValue: String) {
        do {
            let todoItem = todoItems.filter(id == idValue).limit(1)
            try db.run(todoItem.delete())
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
