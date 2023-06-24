//
//  HeaderView.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//
import UIKit

class HeaderView: UIView {
    
    weak var tableViewDelegate: TableView?
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Свернуть", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpViews()
        setupConstraints()
    }
    
    private func setUpViews() {
        self.addSubview(button)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc private func buttonTapped() {
        guard let tableViewDelegate else { return }
        tableViewDelegate.isExpanded ? button.setTitle("Развернуть", for: .normal) : button.setTitle("Свернуть", for: .normal)
        tableViewDelegate.isExpanded = !tableViewDelegate.isExpanded
        UIView.animate(withDuration: 0.4) {
            tableViewDelegate.reloadSections(IndexSet(integer: 0), with: .fade)
        }
    }

}

