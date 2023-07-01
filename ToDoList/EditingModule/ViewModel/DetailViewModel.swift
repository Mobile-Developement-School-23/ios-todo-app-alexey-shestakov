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
    
    
    func saveChangesItemToDataBase(text: String, importanceSegment: Int, deadline: Date?) {
        var importance: Importance = .normal
        switch importanceSegment {
        case 0: importance = .unimportant
        case 2: importance = .important
        default:
            break
        }
        guard let id, let dateCreation, let index else {return}
        let toDoItem = TodoItem(id: id,
                                text: text,
                                importance: importance,
                                deadline: deadline,
                                dateCreation: dateCreation,
                                dateChanging: Date().localDate())
        dataBase.toDoList[index] = toDoItem
        dataBase.saveTask(item: toDoItem)
        dataBase.filterArray()
    }
    
    func saveNewItemToDataBase(text: String, importanceSegment: Int, deadline: Date?) {
        var importance: Importance = .normal
        switch importanceSegment {
        case 0: importance = .unimportant
        case 2: importance = .important
        default:
            break
        }
        let toDoItem = TodoItem(text: text,
                                importance: importance,
                                deadline: deadline,
                                dateCreation: Date().localDate())
        dataBase.toDoList.append(toDoItem)
        dataBase.saveTask(item: toDoItem)
        dataBase.filterArray()
    }
    
    func removeFromDB() {
        guard let id, let index else {return}
        dataBase.toDoList.remove(at: index)
        dataBase.removeTask(id: id)
        dataBase.filterArray()
    }
}
