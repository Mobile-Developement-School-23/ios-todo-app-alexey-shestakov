//
//  Int + extensions.swift
//  First_App
//
//  Created by Alexey Shestakov on 10.03.2023.
//

import Foundation

extension Int {
    
    func getTimeFromsSeconds() -> String {
        if self / 60 == 0 {
            return "\(self % 60) sec"
        }
        
        if self % 60 == 0 {
            return "\(self / 60) min"
        }
        
        return "\(self / 60) min \(self % 60) sec"
    }
    
    func convertSeconds() -> (Int, Int) {
        let min = self / 60
        let sec = self % 60
        return (min, sec)
    }
    
    // метод, который будет подставлять 0, начение секунд меньше 9
    func setZeroForSeconds() -> String {
        Double(self) / 10.0 < 1 ? "0\(self)" : "\(self)"
    }
}
