//
//  UIStackView + Extension.swift
//  First_App
//
//  Created by Alexey Shestakov on 28.02.2023.
//

import UIKit

/*
 Как бы сделали если бы делали без extension
 
 let stackView = UIStackView()
 stackView.addArrangedSubView(YourView1)
 stackView.addArrangedSubView(YourView2)
 stackView.addArrangedSubView(YourView3)
 
 stackView.axis = .horizontal
 stackView.spacing = 10
 stackView.translatesAutoresizingMaskIntoConstraints = false
 */

extension UIStackView {
    convenience init(arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = axis
        self.spacing = spacing
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
