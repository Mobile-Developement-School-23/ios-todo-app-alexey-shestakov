//
//  TableView.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 18.06.2023.
//

import Foundation

import Foundation
import UIKit

protocol TableViewMainProtocol: AnyObject {
    func getViewModel() -> TableViewViewModelType?
    func cellTapped(withViewModel viewModel: DetailViewModelType?)
}

class TableView: UITableView {
    
    weak var mainViewControllerDelegate: MainViewController?
    
    var isExpanded = true
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: .zero, style: style)
        setDelegated()
        configure()
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
        backgroundColor = .none
        separatorStyle = .singleLine
        showsVerticalScrollIndicator = true
        estimatedRowHeight = 100
        rowHeight = UITableView.automaticDimension
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    lazy var setUpHeader = { [weak self] in
        guard let self else {return}
        let tableHeaderView = HeaderView(frame: CGRect(x: 0, y: 0,
                                                       width: self.mainViewControllerDelegate?.view.frame.size.width ?? 0,
                                                       height: (self.mainViewControllerDelegate?.view.frame.size.height ?? 0)/20))
        tableHeaderView.tableViewDelegate = self
        self.tableHeaderView = tableHeaderView
    }
}

extension TableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let mainViewControllerDelegate,
              let viewModel = mainViewControllerDelegate.getViewModel() else { return 0 }

        return isExpanded ?  viewModel.numberOfRows() : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.idTableViewCell, for: indexPath) as? TableViewCell,
                let viewModel = mainViewControllerDelegate?.getViewModel() else {return UITableViewCell()}
        
        let cellViewModel = viewModel.cellViewModel(forIndexPath: indexPath)
        
        cell.viewModel = cellViewModel
        
        return cell
    }
}

extension TableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = mainViewControllerDelegate?.getViewModel() else {return}
        
        // генерируем вьюМодель для выбранной по indexPath ячейке
        let detailViewModel = viewModel.viewModelForSelectedRow(forIndexPath: indexPath)
        
        // переход на другой экран и передача значения
        mainViewControllerDelegate?.cellTapped(withViewModel: detailViewModel)
    }
}
