//
//  ItemModel.swift
//  ToDoList-SwiftUI
//
//  Created by Alexey Shestakov on 19.07.2023.
//

import Foundation

public struct TodoItem: Hashable {
    let id: String
    var text: String
    let importance: Importance
    let deadline: Date?
    let done: Bool
    let dateCreation: Date
    let dateChanging: Date?
    
    init(id: String = UUID().uuidString, text: String, importance: Importance, deadline: Date? = nil, done: Bool = false, dateCreation: Date, dateChanging: Date? = Date().localDate()) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.done = done
        self.dateCreation = dateCreation
        self.dateChanging = dateChanging
    }
    
    func updateCompletion() -> TodoItem {
        return TodoItem(id: id,
                        text: text,
                        importance: importance,
                        deadline: deadline,
                        done: !done,
                        dateCreation: dateCreation,
                        dateChanging: dateChanging)
    }
}

public enum Importance: String {
    case unimportant = "неважная"
    case normal = "обычная"
    case important = "важная"
}

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        
        guard let dictionary = json as? [String: Any],
              let id = dictionary["id"] as? String,
              let text = dictionary["text"] as? String,
              let dateCreationInt = dictionary["dateCreation"] as? Int else { return nil }
        
        
        let done = (dictionary["done"] as? Bool) ?? false
        let dateCreation = Date(timeIntervalSince1970: TimeInterval(dateCreationInt))
        
        var importance: Importance = .normal
        if let importanceRawValue = dictionary["importance"] as? String {
            importance = Importance(rawValue: importanceRawValue) ?? .normal
        }
        
        var deadline: Date?
        if let deadlineInt = dictionary["deadline"] as? Int {
            deadline = Date(timeIntervalSince1970: TimeInterval(deadlineInt))
        }
        
        var dateChanging: Date?
        if let dateChangingInt = dictionary["dateChanging"] as? Int {
            dateChanging = Date(timeIntervalSince1970: TimeInterval(dateChangingInt))
        }
        
        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, done: done, dateCreation: dateCreation, dateChanging: dateChanging)
    }
    
    var json: Any {
        var dictionary: [String: Any] = [
            "id": id,
            "text": text,
            "done": done,
            "dateCreation": Int(dateCreation.timeIntervalSince1970),
        ]
        
        if importance != .normal {
            dictionary["importance"] = importance.rawValue
        }
        
        if let deadline = deadline {
            dictionary["deadline"] = Int(deadline.timeIntervalSince1970)
        }
        
        if let dateChanging = dateChanging {
            dictionary["dateChanging"] = Int(dateChanging.timeIntervalSince1970)
        }
        return dictionary
    }
}
