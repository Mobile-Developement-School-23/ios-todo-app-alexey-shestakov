//
//  TableViewCellViewModel.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//

import Foundation

class TableViewCellViewModel: TableViewCellViewType {
    private let dataBase: DataBase
    
    private let index: Int
     
    var task: String {
        return dataBase.toDoList[index].text
    }
    
    var importance: Importance {
        return dataBase.toDoList[index].importance
    }
    
    var deadline: String? {
        guard let deadline = dataBase.toDoList[index].deadline?.stringFromDateShort() else {return nil}
        return deadline
    }
    
    var done: Bool {
        return dataBase.toDoList[index].done
    }
    
    init(dataBase: DataBase, index: Int) {
        self.dataBase = dataBase
        self.index = index
    }
    
    func makeDoneUndone() {
        let todoItem = TodoItem(id: dataBase.toDoList[index].id,
                                text: dataBase.toDoList[index].text,
                                importance: dataBase.toDoList[index].importance,
                                deadline: dataBase.toDoList[index].deadline,
                                done: !dataBase.toDoList[index].done,
                                dateCreation: dataBase.toDoList[index].dateCreation,
                                dateChanging: Date().localDate())
        dataBase.toDoList[index] = todoItem
        dataBase.saveTask(item: todoItem)
        dataBase.filterArray()
    }
    
    func deleteItem(index: Int) {
        let todoItem = dataBase.toDoList[index]
        dataBase.toDoList.remove(at: index)
        dataBase.removeTask(id: todoItem.id)
    }
}
