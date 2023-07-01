//
//  DataBase.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//

import Foundation

class DataBase {
    
    let cache = FileCache()
    
    var mainViewModelDelegate: MainViewModel?
    
    var toDoList = [TodoItem]()
    
    var typeSorting: SortedBy = .none
    
    var isFiltered = false
    
    public func filterArray() {
        tasksExtractor()
        guard isFiltered else {return}
        switch typeSorting {
        case .onlyImportantAndNotDone:
            toDoList = toDoList.filter {$0.importance == .important}.filter {$0.done != true}
        case .onlyNotDone:
            toDoList = toDoList.filter {$0.done != true}
        case .onlyImportant:
            toDoList = toDoList.filter {$0.importance == .important}
        case .none:
            break
        }
    }
    
    public func saveTask(item: TodoItem) {
        cache.add(item: item)
        countDone()
        try? self.cache.saveToJson(toFileWithID: fileName)
    }
    
    public func removeTask(id: String) {
        cache.remove(id: id)
        countDone()
        try? self.cache.saveToJson(toFileWithID: fileName)
    }
    
    @discardableResult
    public func countDone() -> Int {
        let array = cache.items.values.filter {$0.done == true}
        mainViewModelDelegate?.numberDoneTasks.value = array.count
        return array.count
    }
    
    lazy var tasksExtractor = { [weak self] in
        guard let self else {return}
        try? self.cache.loadFromJson(from: fileName)
        self.toDoList = Array(self.cache.items.values)
        self.toDoList.sort{$0.dateCreation > $1.dateCreation}
    }
    
    
    
    
    
    //MARK: - Это тестовые данные, чтобы можно было сохранить в дирректорию!!!
    lazy var tasksSaver = {
        let cache = FileCache()
        
        var tasksToWrite = [
            TodoItem(id: "1", text: """
Я помню чудное мгновенье:
Передо мной явилась ты,
Как мимолетное виденье,
Как гений чистой красоты.

В томленьях грусти безнадежной,
В тревогах шумной суеты,
Звучал мне долго голос нежный
И снились милые черты.

Шли годы. Бурь порыв мятежный
Рассеял прежние мечты,
И я забыл твой голос нежный,
Твои небесные черты.
""",
                     importance: .important, deadline: Date().localDate().offsetDays(days: 3), done: true, dateCreation: Date().localDate().offsetDays(days: -2)),
            
            TodoItem(id: "2", text: "Я помню чудное мгновенье:", importance: .important, deadline: Date().localDate().offsetDays(days: 5), done: false, dateCreation: Date().localDate().offsetDays(days: -6)),

            TodoItem(id: "3", text: "У лукоморья дуб зеленый", importance: .unimportant, deadline: nil, done: true, dateCreation: Date().localDate().offsetDays(days: 0))
        ]
        for item in tasksToWrite {
            self.cache.add(item: item)
        }
        try? self.cache.saveToJson(toFileWithID: "myTasksJson")
    }
    
    

    
    init() {
        /// Обращаемся к файлам вида json и csv и достаем из них данные, записывая их в toDoList
        tasksSaver()
        tasksExtractor()
        
    }
    
}


enum SortedBy: String {
    case onlyImportant = "Важные"
    case onlyNotDone = "Несделанные"
    case none = "Все"
    case onlyImportantAndNotDone = "Важные и несделанные"
}

let fileName = "myTasksJson"
