//
//  TableViewCell.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    weak var tableViewDelegate: TableView?
    
    var viewModel: TableViewCellViewType?
    
    static let idTableViewCell = "idTableViewCell"

    let checkmark: UIImageView = {
        let imageV = UIImageView()
        imageV.translatesAutoresizingMaskIntoConstraints = false
        imageV.contentMode = .center
        return imageV
    }()
    
    let openArrow: UIImageView = {
        let imageV = UIImageView()
        imageV.translatesAutoresizingMaskIntoConstraints = false
        imageV.image = UIImage(named: "right_arrow")
        imageV.contentMode = .scaleAspectFill
        return imageV
    }()
    
    let importanceImage: UIImageView = {
        let imageV = UIImageView()
        imageV.contentMode = .center
        imageV.translatesAutoresizingMaskIntoConstraints = false
        imageV.image = UIImage(named: "Important")
        return imageV
    }()
    
    let task: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.tintColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let calendarView: UIImageView = {
        let imageV = UIImageView()
        imageV.contentMode = .center
        imageV.translatesAutoresizingMaskIntoConstraints = false
        imageV.image = UIImage(named: "calendar")
        return imageV
    }()
    
    let deadlineLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separator: UIView = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.isHidden = false
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var corners: UIRectCorner = []
    
    var verticalStackView = UIStackView()
    
    var lowerStackView = UIStackView()
    
    var superStackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
        setUpConstraints()
        addGesture()
        prepareForReuse()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let shape = CAShapeLayer()
        let rect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.size.height)
        shape.path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: 16, height: 16)).cgPath
        layer.mask = shape
        layer.masksToBounds = true
    }
    
    private func setUpViews() {
        backgroundColor = .white
        selectionStyle = .none
        
        lowerStackView = UIStackView(arrangedSubviews: [calendarView, deadlineLabel],
                                axis: .horizontal,
                                spacing: 3)
        lowerStackView.alignment = .leading
        
        verticalStackView = UIStackView(arrangedSubviews: [task, lowerStackView],
                                     axis: .vertical,
                                     spacing: 0)
        verticalStackView.alignment = .leading
        
        superStackView = UIStackView(arrangedSubviews: [importanceImage, verticalStackView],
                                     axis: .horizontal,
                                     spacing: 10)
        superStackView.distribution = .fillProportionally
        
        contentView.addSubview(containerView)
        containerView.addSubview(superStackView)
        containerView.addSubview(checkmark)
        containerView.addSubview(separator)
        containerView.addSubview(openArrow)
    }
    
    
    func configure() {
        task.text = viewModel?.task
        if viewModel?.importance == .important {
            importanceImage.isHidden = false
        } else {
            importanceImage.isHidden = true
        }
        if let deadline = viewModel?.deadline {
            deadlineLabel.text = deadline
            lowerStackView.isHidden = false
        } else {
            lowerStackView.isHidden = true
        }
        setChecked()
    }
    
    func setNewTitle(text: String) {
        separator.isHidden = true
        task.text = text
        task.textColor = .lightGray
    }
    
    func setChecked() {
        guard let viewModel else {return}
        if viewModel.done {
            checkmark.image = UIImage(named: "checkmark_done")
            checkmark.tintColor = .systemBlue
        } else if viewModel.importance != .important {
            checkmark.image = UIImage(named: "checkmark_not_done")
        } else {
            checkmark.image = UIImage(named: "importantCheck")
        }
        setCrossed()
    }
    
    func setCrossed() {
        guard let viewModel else {return}
        if viewModel.done {
            task.textColor = .lightGray
            let attributedString = NSAttributedString(string: task.text ?? "", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            task.attributedText = attributedString
        } else {
            task.textColor = .black
            let attributedString = NSAttributedString(string: task.text ?? "", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.self])
            task.attributedText = attributedString
        }
    }
    
    private func addGesture() {
        let tapScreen = UITapGestureRecognizer(target: self, action: #selector(tap))
        checkmark.isUserInteractionEnabled = true
        checkmark.addGestureRecognizer(tapScreen)

    }
    
    @objc func tap() {
        setChecked()
        viewModel?.makeDoneUndone()
        tableViewDelegate?.reloadData()
    }
}


extension TableViewCell {
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            importanceImage.widthAnchor.constraint(equalToConstant: 10),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            checkmark.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmark.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            checkmark.heightAnchor.constraint(equalToConstant: 30),
            checkmark.widthAnchor.constraint(equalToConstant: 30),

            openArrow.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            openArrow.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            openArrow.heightAnchor.constraint(equalToConstant: 14),
            openArrow.widthAnchor.constraint(equalToConstant: 8),

            superStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            superStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            superStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            superStackView.leadingAnchor.constraint(equalTo: checkmark.trailingAnchor, constant: 16),

            separator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            separator.leadingAnchor.constraint(equalTo: superStackView.leadingAnchor),

        ])
    }
}
