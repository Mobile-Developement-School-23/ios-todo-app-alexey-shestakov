//
//  Notification.Name+extension.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 20.06.2023.
//

import Foundation

extension Notification.Name {
    static let editingStarted = Notification.Name("Editing Started")
    static let hasNoText = Notification.Name("No text")
    static let reloadData = Notification.Name("reloadData")
}
