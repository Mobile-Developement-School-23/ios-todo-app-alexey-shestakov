//
//  TableViewCellViewType.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//

import Foundation

protocol TableViewCellViewType: AnyObject {
    var task: String {get}
    var importance: Importance {get}
    var done: Bool {get}
    var deadline: String? {get}
    func deleteItem(index: Int)
    func makeDoneUndone()
}
