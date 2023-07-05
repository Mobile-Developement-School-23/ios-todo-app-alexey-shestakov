//
//  TableViewViewModelType.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//

import Foundation

protocol TableViewViewModelType {
    var numberDoneTasks: Observable<Int?> {get set}
    func sortItems(typeSorting: SortedBy)
    func returnModel() -> DataBase
    func numberOfRows() -> Int
    func cellViewModel(forIndexPath indexPath: IndexPath) -> TableViewCellViewType?
    func viewModelForSelectedRow(forIndexPath indexPath: IndexPath) -> DetailViewModelType?
    func deleteItem(index: Int)
}
