//
//  DataBase.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//

import Foundation

class DataBase {
    
    let cache = FileCache()
    
    // В этот toDoList мы ничего не записываем, он нужен лишь для отображения данных
    var toDoList = [TodoItem]()
    
    
    public func saveTask(item: TodoItem) {
        cache.add(item: item)
        do {
            try self.cache.saveToJson(toFileWithID: "myTasksJson")
            print("Задача успешно сохранена в файл")
        } catch {
            print("Ошибка при сохранении задачи: \(error)")
            return
        }
    }
    
    public func removeTask(id: String) {
        cache.remove(id: id)
        do {
            try self.cache.saveToJson(toFileWithID: "myTasksJson")
        } catch {
            print("Ошибка при сохранении задач: \(error)")
            return
        }
    }
    
    
    
    
    
    
    /// Это тестовые данные, чтобы можно было сохранить в дирректорию
    lazy var tasksSaver = {
        /// Это локальный fileChace который запишет данные в файл
        let cache = FileCache()
        
        var tasksToWrite = [
            TodoItem(id: "1", text: "Завершить проект", importance: .important, deadline: Date().localDate().offsetDays(days: 5), done: false, dateCreation: Date().localDate())
        ]
        
        for item in tasksToWrite {
            self.cache.add(item: item)
        }
        
        do {
            try self.cache.saveToJson(toFileWithID: "myTasksJson")
            print("Задача успешно сохранена в файл")
        } catch {
            print("Ошибка при сохранении задачи: \(error)")
            return
        }
    }
    
    
    
    lazy var tasksExtractor = { [weak self] in
        guard let self else {return}
        do {
            try self.cache.loadFromJson(from: "myTasksJson")
            print("Задачи успешно загружены из файла")
        } catch {
            print("Ошибка при загрузке задач: \(error)")
            return
        }
        
        self.toDoList = Array(self.cache.items.values)
        for item in self.toDoList {
            print(item.text)
        }
    }
    
    init() {
        /// Обращаемся к файлам вида json и csv и достаем из них данные, записывая их в toDoList
        tasksSaver()
        tasksExtractor()
        
    }
    
}
