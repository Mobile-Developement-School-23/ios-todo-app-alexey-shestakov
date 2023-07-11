//
//  TodoItemPersiatence+CoreDataProperties.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 10.07.2023.
//
//

import Foundation
import CoreData


extension TodoItemPersiatence {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItemPersiatence> {
        return NSFetchRequest<TodoItemPersiatence>(entityName: "TodoItemPersiatence")
    }


    @NSManaged public var id: String
    @NSManaged public var text: String
    @NSManaged public var importanceValue: String
    var importance: Importance {
        get {
            Importance(rawValue: importanceValue) ?? .normal
        }
        set {
            Importance(rawValue: newValue.rawValue) ?? <#default value#>
        }
    }
    @NSManaged public var deadline: Date?
    @NSManaged public var done: Bool
    @NSManaged public var dateCreation: Date
    @NSManaged public var dateChanging: Date?

}

extension TodoItemPersiatence : Identifiable {

}
