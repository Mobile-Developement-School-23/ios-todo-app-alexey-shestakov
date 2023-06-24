//
//  UIView + Extensions.swift
//  First_App
//
//  Created by Alexey Shestakov on 24.02.2023.
//

import UIKit

extension UIView {
    
    convenience init(backGroundColor: UIColor, cornerRadius: Double) {
        self.init(frame: .zero)
        self.backgroundColor = backGroundColor
        self.layer.cornerRadius = cornerRadius
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addShadowOnView() {
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 1
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
