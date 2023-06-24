//
//  TableViewViewModelType.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//

import Foundation

protocol TableViewViewModelType {
    func numberOfRows() -> Int
    func cellViewModel(forIndexPath indexPath: IndexPath) -> TableViewCellViewType?
    func viewModelForSelectedRow(forIndexPath indexPath: IndexPath) -> DetailViewModelType?
}
