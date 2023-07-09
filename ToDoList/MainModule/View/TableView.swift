//
//  TableView.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//

import UIKit

protocol TableViewMainProtocol: AnyObject {
    func getViewModel() -> TableViewViewModelType?
    func cellTapped(withViewModel viewModel: DetailViewModelType?, selectedCell: TableViewCell)
}

class TableView: UITableView {
    
    weak var mainViewControllerDelegate: MainViewController?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: .zero, style: style)
        setDelegated()
        configure()
        addObserver()
        register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.idTableViewCell)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setDelegated() {
        dataSource = self
        delegate = self
    }
    
    private func configure() {
        backgroundColor = .clear
        separatorStyle = .none
        
        showsVerticalScrollIndicator = true
        estimatedRowHeight = 100
        rowHeight = UITableView.automaticDimension
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var setUpHeader = { [weak self] in
        guard let self, let viewModel = self.mainViewControllerDelegate?.getViewModel() else {return}
        let cgRect = CGRect(x: 0, y: 0,
                            width: self.mainViewControllerDelegate?.view.frame.size.width ?? 0,
                            height: (self.mainViewControllerDelegate?.view.frame.size.height ?? 0)/16)
        let tableHeaderView = HeaderView(frame: cgRect)
        tableHeaderView.mainViewModel = viewModel
        tableHeaderView.tableViewDelegate = self
        tableHeaderView.configure()
        self.tableHeaderView = tableHeaderView
    }
    
    lazy var setUpFooter = { [weak self] in
        guard let self else {return}
        let tableFooterView = FooterView(frame: CGRect(x: 0, y: 0,
                                                       width: self.mainViewControllerDelegate?.view.frame.size.width ?? 0,
                                                       height: 60))
        tableFooterView.tableViewDelegate = self
        self.tableFooterView = tableFooterView
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: .reloadData, object: nil)
    }
    
    @objc func reloadTableView() {
        reloadData()
    }
}

extension TableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let mainViewControllerDelegate,
              let viewModel = mainViewControllerDelegate.getViewModel() else { return 0 }
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.idTableViewCell, for: indexPath) as? TableViewCell,
              let viewModel = mainViewControllerDelegate?.getViewModel() else {return UITableViewCell()}
        let cellViewModel = viewModel.cellViewModel(forIndexPath: indexPath)
        cell.viewModel = cellViewModel
        cell.tableViewDelegate = self
        cell.configure()
        return cell
    }
    
    /// метод закругляет края у верхней и нижней ячейки
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? TableViewCell {
            if indexPath.row == 0 {
                cell.corners = [.topLeft, .topRight]
            } else {
                cell.corners = []
            }
        }
    }
    
    
    ///Функционал оттягивания ячеек
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell else {return nil}
        ///delete
        let delete = UIContextualAction(style: .destructive, title: "") { _, _, _ in
            cell.viewModel?.deleteItem(index: indexPath.row)
            tableView.reloadData()
        }
        delete.image = UIImage(named: "trash")
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        return swipe
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell else {return nil}
        ///done
        let done = UIContextualAction(style: .normal, title: "") { _, _, completion in
            cell.setChecked()
            cell.viewModel?.makeDoneUndone()
            tableView.reloadData()
            completion(true)
        }
        done.image = UIImage(named: "checkmark_done")
        done.backgroundColor = .systemBlue
        let swipe = UISwipeActionsConfiguration(actions: [done])
        return swipe
    }
}

extension TableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = mainViewControllerDelegate?.getViewModel(),
              let selectedCell = tableView.cellForRow(at: indexPath) as? TableViewCell else {return}
        let detailViewModel = viewModel.viewModelForSelectedRow(forIndexPath: indexPath)
        mainViewControllerDelegate?.cellTapped(withViewModel: detailViewModel, selectedCell: selectedCell)
        UIView.animate(withDuration: 0.3) {
            selectedCell.backgroundColor = .customLightGray
        } completion: { _ in
            selectedCell.backgroundColor = .white
        }

    }
}

//MARK: - ContextualMenu
extension TableView {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point _: CGPoint) -> UIContextMenuConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell else {return nil}
        let index = indexPath.row
        let identifier = "\(index)" as NSString
        return UIContextMenuConfiguration(
            identifier: identifier,
            previewProvider: nil,
            actionProvider: { _ in
                let inspectAction =
                UIAction(title: NSLocalizedString("Отметить сделанным", comment: ""),
                         image: UIImage(systemName: "checkmark"))
                { _ in
                    ///Действия выполняются именно в таком порядке
                    cell.setChecked()
                    cell.viewModel?.makeDoneUndone()
                    tableView.reloadData()
                }
                let deleteAction =
                UIAction(title: NSLocalizedString("Удалить", comment: ""),
                         image: UIImage(systemName: "trash"),
                         attributes: .destructive)
                { _ in
                    cell.viewModel?.deleteItem(index: index)
                    self.reloadData()
                }
                return UIMenu(title: "", children: [inspectAction, deleteAction])
            }
        )
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let identifier = configuration.identifier as? String,
              let index = Int(identifier),
              let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TableViewCell else { return }
        animator.addCompletion {
            guard let viewModel = self.mainViewControllerDelegate?.getViewModel() else {return}
            let detailViewModel = viewModel.viewModelForSelectedRow(forIndexPath: IndexPath(row: index, section: 0))
            self.mainViewControllerDelegate?.cellTapped(withViewModel: detailViewModel, selectedCell: cell)
        }
    }
}
