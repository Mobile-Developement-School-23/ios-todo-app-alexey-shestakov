//
//  Date + extensions.swift
//  First_App
//
//  Created by Alexey Shestakov on 11.03.2023.
//

import Foundation

extension Date {
    
    func getNumberOfDay() -> Int {
        let calendar = Calendar.current //current - тот календарь который на устройстве
        let weekday = calendar.component(.weekday, from: self)  // В self придет дата, для которой будем применять метод
        return weekday
    }
    
    func localDate() -> Date {          // С этой штукой осторожней, она добавляет секунды
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))              //Смещение в секундах
        let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: self) ?? Date()
        print(localDate)
        return localDate
    }
    
    func getWeekArray() -> [[String]] {
        let formater = DateFormatter()
        formater.locale =  Locale(identifier: "en_GB")
        formater.dateFormat = "EEEEEE"
        let calendar = Calendar.current
        
        var weekArray : [[String]] = [[], []]
        for i in -6...0 {
            let date = calendar.date(byAdding: .day, value: i, to: self) ?? Date()  // Получаем дату со всеми возможными параметрами
            let day = calendar.component(.day, from: date) // Нас надо получить из этой даты только день
            weekArray[1].append("\(day)")
            let weekDay = formater.string(from: date)           // Возвращает пн
            weekArray[0].append(weekDay)
        }
        return weekArray
    }
    
    func offsetDays(days: Int) -> Date {
        let offsetDays = Calendar.current.date(byAdding: .day, value: -days, to: self) ?? Date()
        return offsetDays
    }
    
    func offsetMonths(months: Int) -> Date {
        let offsetMonths = Calendar.current.date(byAdding: .month, value: -months, to: self) ?? Date()
        return offsetMonths
    }
    
    func onlyDate() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        guard let date = date else {return Date()}
        return date.localDate()
    }
    
    func dayMonthYearString() -> String {
        let formater = DateFormatter()
        formater.locale =  Locale(identifier: "en_GB")
        formater.dateFormat = "dd.MM.yy"
        return formater.string(from: self)
    }
    
    
    // Чтобы создавать айди для тренировки и неважно сколько упражнений было создано (создаем уведомление для дня, а не для каждой тренировки в дне)
    func ddMMYYYYFromDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let date = formatter.string(from: self)
        return date
    }
}










extension Date {
    // Получаем промежуток даты - по которому будем искать в модели, пр 18.03 00:00 - 19.03 00:00
//    func startEndDate() -> (start: Date, end: Date) {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd"
//
////        let calendar = Calendar.current
////        let day = calendar.component(.day, from: self)        //Сборка даты
////        let month = calendar.component(.month, from: self)
////        let year = calendar.component(.year, from: self)
////        let dateStart = formatter.date(from: "\(year)/\(month)/\(day)") ?? Date()
////        let local = dateStart.localDate()
//
//        let stringDate = formatter.string(from: self)
//        let totalDate = formatter.date(from: stringDate) ?? Date()
//
//        let local = totalDate.localDate()
//        let dateEnd : Date = {
////            let components = DateComponents(day: 1) // Чтобы получить конечную дату прибавим 1 день
////            return calendar.date(byAdding: components, to: local) ?? Date()
//            return local.offsetDays(day: -1) // "-" так как в функции выше с - (шли в обратном направлении). Чтобы не захватывать следующий день можно прибавлять секунды в сутках-1
//        }()
//        return (local, dateEnd)
//    }
}
