//
//  MainiViewModel.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//

import Foundation

class MainViewModel: TableViewViewModelType {
    
    var model = DataBase()
    
    func numberOfRows() -> Int {
        return model.toDoList.count
    }
    
    // задача нашей вьюмодели просто передать этот профиль дальше, чтобы следующая вьюмодель с ним работала
    // TableViewCellViewModel - следующая вьюмодель для заполнения ячейки а не всей таблицы
    func cellViewModel(forIndexPath indexPath: IndexPath) -> TableViewCellViewType? {
        let todoItem = model.toDoList[indexPath.row]
        return TableViewCellViewModel(todoItem: todoItem)
    }
    
    // будет создавать вьюМодель для экрана с детализированной информацией
    func viewModelForSelectedRow(forIndexPath indexPath: IndexPath) -> DetailViewModelType? {
        return DetailViewModel(dataBase: model, index: indexPath.row)
    }
}
