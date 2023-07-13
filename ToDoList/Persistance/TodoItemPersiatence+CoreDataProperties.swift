//
//  TodoItemPersiatence+CoreDataProperties.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 10.07.2023.
//
//

import Foundation
import CoreData

@objc(TodoItemPersiatence)
public class TodoItemPersiatence: NSManagedObject {

}

extension TodoItemPersiatence {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItemPersiatence> {
        return NSFetchRequest<TodoItemPersiatence>(entityName: "TodoItemPersiatence")
    }
    
    @NSManaged public var id: String
    @NSManaged public var text: String
    @NSManaged private var importanceValue: String
    public var importance: Importance {
        get {
            Importance(rawValue: importanceValue) ?? .normal
        }
        set {
            importanceValue = newValue.rawValue
        }
    }
    @NSManaged public var deadline: Date?
    @NSManaged public var done: Bool
    @NSManaged public var dateCreation: Date
    @NSManaged public var dateChanging: Date?

}

extension TodoItemPersiatence : Identifiable {

}
