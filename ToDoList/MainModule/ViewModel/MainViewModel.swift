//
//  MainiViewModel.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//

import Foundation

class MainViewModel: TableViewViewModelType {
    
    private let model: DataBase
    
    var loadFromServer: Observable<Bool> = Observable(false)
    
    var numberDoneTasks: Observable<Int?> = Observable(nil)
    
    init() {
        self.model = DataBase()
        model.mainViewModelDelegate = self
    }
    
    func returnModel() -> DataBase {
        return model
    }
    
    func numberOfRows() -> Int {
        return model.toDoList.count
    }

    func cellViewModel(forIndexPath indexPath: IndexPath) -> TableViewCellViewType? {
        return TableViewCellViewModel(dataBase: model, index: indexPath.row)
    }
    
    func viewModelForSelectedRow(forIndexPath indexPath: IndexPath) -> DetailViewModelType? {
        return DetailViewModel(dataBase: model, index: indexPath.row)
    }
    
    func sortItems(typeSorting: SortedBy) {
        switch typeSorting {
        case .onlyNotDone:
            model.typeSorting = .onlyNotDone
        case .none:
            model.typeSorting = .none
        case .onlyImportantAndNotDone:
            model.typeSorting = .onlyImportantAndNotDone
        }
        model.filterArray()
    }
}
