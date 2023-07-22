//
//  Extensions.swift
//  ToDoList-SwiftUI
//
//  Created by Alexey Shestakov on 19.07.2023.
//

import SwiftUI

class ColorAdditional {
    static let specialBackground = #colorLiteral(red: 0.975140512, green: 0.9716036916, blue: 0.9593529105, alpha: 1)
    static let specialGray = #colorLiteral(red: 0.3176470588, green: 0.3176470588, blue: 0.3137254902, alpha: 1)
    static let customLightGray = #colorLiteral(red: 0.9058823529, green: 0.968627451, blue: 0.9843137255, alpha: 1)
}

extension Date {
    
    func localDate() -> Date {
        /// Ко всем датам при инициализации объектов применять следующий код
        /// Он переводит время в локальное - неважно текущее оно или прошлое/будущее. Date() - считает по гринвичу
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
        let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: self) ?? Date()
        return localDate
    }
    
    func stringFromDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: self)
    }
    
    func stringFromDateShort() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: self)
    }
    
    func offsetDays(days: Int) -> Date {
        let offsetDays = Calendar.current.date(byAdding: .day, value: days, to: self) ?? Date()
        return offsetDays
    }
}


extension Optional where Wrapped == String {
    private var _bound: String? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    public var bound: String {
        get {
            return _bound ?? ""
        }
        set {
            _bound = newValue.isEmpty ? nil : newValue
        }
    }
}

extension Optional where Wrapped == Date {
    private var _bound: Date? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    public var bound: Date {
        get {
            return _bound ?? Date()
        }
        set {
            _bound = newValue
        }
    }
}
