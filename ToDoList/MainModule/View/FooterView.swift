//
//  FooterView.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//
import UIKit

class FooterView: UIView {
    
    weak var tableViewDelegate: TableView?
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Новое"
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var corners: UIRectCorner = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
        setupConstraints()
        addGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        backgroundColor = .white
        addSubview(label)
    }
    
    
    override func layoutSubviews() {
        if tableViewDelegate?.numberOfRows(inSection: 0) == 0 {
            corners = [.allCorners]
        } else {
            corners = [.bottomRight, .bottomLeft]
        }
        super.layoutSubviews()
        let shape = CAShapeLayer()
        let rect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.size.height)
        shape.path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: 16, height: 16)).cgPath
        layer.mask = shape
        layer.masksToBounds = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 65),
        ])
    }
    
    private func addGesture() {
        let tapScreen = UITapGestureRecognizer(target: self, action: #selector(addNew))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapScreen)

    }
    
    @objc private func addNew() {
        UIView.animate(withDuration: 0.15, animations: {
            self.label.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { (bool) in
            self.label.transform = .identity
            self.tableViewDelegate?.mainViewControllerDelegate?.addTask()
        }
    }

}

