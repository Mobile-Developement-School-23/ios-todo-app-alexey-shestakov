//
//  TableViewCellViewModel.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//

import Foundation

// Эта модель создается когда в нее передают profile - поэтому это будет ее свойство и инициализатор

// Что мы ждем от этой модели? Мы от нее ждем данные, с помощью которых мы сможем заполнить ячейку (age и fullname).
// Эта модель должна ПОДГОТОВИТЬ fullname, age

class TableViewCellViewModel: TableViewCellViewType {
    
    private var todoItem: TodoItem
    
    var task: String {
        return todoItem.text
    }
    
    init(todoItem: TodoItem) {
        self.todoItem = todoItem
    }
}
