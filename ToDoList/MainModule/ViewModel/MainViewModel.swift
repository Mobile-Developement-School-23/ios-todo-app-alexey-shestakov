//
//  MainiViewModel.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//

import Foundation

class MainViewModel: TableViewViewModelType {
    
    private let model: DataBase
    
    
    init(model: DataBase = DataBase()) {
        self.model = model
        model.mainViewModelDelegate = self
    }
    
    func returnModel() -> DataBase {
        return model
    }
    
    var numberDoneTasks: Observable<Int?> = Observable(nil)
    
    func numberOfRows() -> Int {
        return model.toDoList.count
    }

    func cellViewModel(forIndexPath indexPath: IndexPath) -> TableViewCellViewType? {
        return TableViewCellViewModel(dataBase: model, index: indexPath.row)
    }
    
    func viewModelForSelectedRow(forIndexPath indexPath: IndexPath) -> DetailViewModelType? {
        return DetailViewModel(dataBase: model, index: indexPath.row)
    }
    
    func deleteItem(index: Int) {
        let todoItem = model.toDoList[index]
        model.toDoList.remove(at: index)
        model.removeTask(id: todoItem.id)
    }
    
    func sortItems(typeSorting: SortedBy) {
        switch typeSorting {
        case .onlyImportant:
            model.isFiltered = true
            model.typeSorting = .onlyImportant
        case .onlyNotDone:
            model.isFiltered = true
            model.typeSorting = .onlyNotDone
        case .none:
            model.isFiltered = false
            model.typeSorting = .none
        case .onlyImportantAndNotDone:
            model.isFiltered = true
            model.typeSorting = .onlyImportantAndNotDone
        }
        model.filterArray()
    }
}
