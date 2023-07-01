//
//  DetailViewModelType.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//

import Foundation

protocol DetailViewModelType: AnyObject {
    
    var id: String? {get}
    
    func getIndex() -> Int?
    
    var text: String? {get}
    
    var importance: Importance? {get}
    
    var deadline: Date? {get}
    var done: Bool? {get}
    
    var dateCreation: Date? {get}
    
    func saveChangesItemToDataBase(text: String, importanceSegment: Int, deadline: Date?)
    
    func saveNewItemToDataBase(text: String, importanceSegment: Int, deadline: Date?)
    
    func removeFromDB()
}
