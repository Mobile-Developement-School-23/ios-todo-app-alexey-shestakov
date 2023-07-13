//
//  Entity+CoreDataProperties.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 11.07.2023.
//
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var importance: NSObject?
    @NSManaged public var deadline: Date?
    @NSManaged public var done: Bool
    @NSManaged public var dateCreation: Date?
    @NSManaged public var dateChanging: Date?

}

extension Entity : Identifiable {

}
