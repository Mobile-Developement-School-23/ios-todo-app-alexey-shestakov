//
//  TableViewCell.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    static let idTableViewCell = "idTableViewCell"
    
    let task: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.tintColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        backgroundColor = .clear
        selectionStyle = .none
        addSubview(task)
    }
    
    var viewModel: TableViewCellViewType? {
        willSet(viewModel) {
            task.text = viewModel?.task
        }
    }
}


extension TableViewCell {
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            
            task.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
            task.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            task.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            task.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30),
        ])
    }
}
