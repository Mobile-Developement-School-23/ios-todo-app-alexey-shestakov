
import Foundation

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
