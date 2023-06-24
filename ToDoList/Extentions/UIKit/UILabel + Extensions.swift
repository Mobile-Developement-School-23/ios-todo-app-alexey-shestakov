//
//  UILabel + Extensions.swift
//  First_App4
//
//  Created by Alexey Shestakov on 27.02.2023.
//

import UIKit


extension UILabel {
    convenience init(textLightBrown: String = "") {
        self.init(frame: .zero)
        self.text = textLightBrown
        self.font = .robotoMedium14()
        self.textColor = .specialLightBrown
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.5
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    convenience init(text: String = "", font: UIFont?, textColor: UIColor, textAligment: NSTextAlignment) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAligment
        self.adjustsFontSizeToFitWidth = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

