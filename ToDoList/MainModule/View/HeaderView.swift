//
//  HeaderView.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//
import UIKit

class HeaderView: UIView {
    
    var mainViewModel: TableViewViewModelType?
    
    weak var tableViewDelegate: TableView?
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("\(SortedBy.onlyNotDone.rawValue)", for: .normal)
        button.layer.cornerRadius = 15
        button.contentHorizontalAlignment = .right
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndocator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
        setupConstraints()
        
        let contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        button.addInteraction(contextMenuInteraction)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        backgroundColor = .specialBackground
        addSubview(button)
        addSubview(label)
        addSubview(activityIndocator)
    }
    
    public func configure() {
        guard let number = mainViewModel?.returnModel().countDone() else {return}
        label.text = "Выполнено - \(number)"
        
        mainViewModel?.numberDoneTasks.bind(listener: { [unowned self] number in
            guard let number else {return}
            label.text = "Выполнено - \(number)"
        })
        
        
        mainViewModel?.networkRequestCompleted.bind(listener: { [unowned self] (completed, makeReload) in
            if completed {
                if makeReload {
                    tableViewDelegate?.reloadData()
                }
                processProgressIndicator(false)
            } else {
                processProgressIndicator(true)
            }
        })
    }
    
    private func processProgressIndicator(_ continueIndicator: Bool) {
        if continueIndicator {
            activityIndocator.startAnimating()
        } else {
            activityIndocator.stopAnimating()
        }
    }
    
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            label.heightAnchor.constraint(equalToConstant: 30),
            
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            button.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 30),
            
            activityIndocator.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
            activityIndocator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    private(set) var wasSorted = false
    
    @objc private func buttonTapped() {
        guard let tableViewDelegate,
              let mainViewModel else { return }
        if !wasSorted {
            mainViewModel.sortItems(typeSorting: .onlyNotDone)
            button.setTitle(SortedBy.none.rawValue, for: .normal)
            wasSorted = true
        } else {
            mainViewModel.sortItems(typeSorting: .none)
            button.setTitle(SortedBy.onlyNotDone.rawValue, for: .normal)
            wasSorted = false
        }
        tableViewDelegate.reloadData()
    }
}

extension HeaderView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let tableViewDelegate, wasSorted else { return nil}
            let menuActions = [
                UIAction(title: NSLocalizedString("Оставить только важные", comment: ""),
                         image: UIImage(named: "Important"))
                { action in
                    self.mainViewModel?.sortItems(typeSorting: .onlyImportantAndNotDone)
                    tableViewDelegate.reloadData()
                },
                UIAction(title: NSLocalizedString("Отменить доп фильтрацию", comment: ""),
                         image: UIImage(systemName: "clear"), attributes: .destructive)
                { action in
                    self.mainViewModel?.sortItems(typeSorting: .onlyNotDone)
                    tableViewDelegate.reloadData()
                }
            ]
            let menu = UIMenu(title: "Дополнительная фильтрация для несделанных задач", children: menuActions)
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
                return menu
            })
        }
}
