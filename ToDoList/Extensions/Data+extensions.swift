
import Foundation

extension Date {
    
    func localDate() -> Date {
        /// Ко всем датам при инициализации объектов применять следующий код
        /// Он переводит время в локальное - неважно текущее оно или прошлое/будущее. Date() - считает по гринвичу
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
        let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: self) ?? Date()
        return localDate
    }
    
}
