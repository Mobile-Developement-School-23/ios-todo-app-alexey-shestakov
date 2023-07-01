//
//  UIView+extensions.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 27.06.2023.
//

import UIKit

extension UIView {
    func addShadowOnView() {
        self.layer.shadowColor = UIColor.specialGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 10)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 10
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
