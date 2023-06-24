//
//  DetailViewModel.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//

import Foundation

class DetailViewModel: DetailViewModelType {
    
    var dataBase: DataBase
    
    private var index: Int?
    
    public func getIndex() -> Int? {
        return index
    }
    
    init(dataBase: DataBase, index: Int?) {
        print(dataBase.toDoList[index!])
        self.dataBase = dataBase
        self.index = index
    }
    
    var id: String? {
        guard let index else {return nil}
        return dataBase.toDoList[index].id
    }
    
    var text: String? {
        guard let index else {return nil}
        return dataBase.toDoList[index].text
    }
    
    var importance: Importance? {
        guard let index else {return nil}
        return dataBase.toDoList[index].importance
    }
    
    var deadline: Date? {
        guard let index else {return nil}
        return dataBase.toDoList[index].deadline
    }
    
    var done: Bool? {
        guard let index else {return nil}
        return dataBase.toDoList[index].done
    }
    
    var dateCreation: Date? {
        guard let index else {return nil}
        return dataBase.toDoList[index].dateCreation
    }
    
    var dateChanging: Date? {
        guard let index else {return nil}
        return dataBase.toDoList[index].dateChanging
    }
    
    
    func saveItemToDataBase(text: String, importanceSegment: Int, deadline: Date?) {
        var importance: Importance = .normal
        switch importanceSegment {
        case 0: importance = .unimportant
        case 1: importance = .normal
        case 2: importance = .important
        default:
            break
        }
        guard let id else {return}
        let toDoItem = TodoItem(id: id,text: text, importance: importance, deadline: deadline, dateCreation: Date().localDate())
        dataBase.saveTask(item: toDoItem)
    }
    
    func removeFromDB() {
        guard let id else {return}
        dataBase.removeTask(id: id)
    }
}
