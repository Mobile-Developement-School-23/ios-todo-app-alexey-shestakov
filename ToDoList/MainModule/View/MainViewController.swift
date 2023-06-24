
import UIKit

class MainViewController: UIViewController {
    
    private var mainViewModel: TableViewViewModelType?
    
    private let tableView = TableView()
    
    convenience init(viewModel: TableViewViewModelType? = nil) {
        self.init()
        self.mainViewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setUpConstraints()
        setUpDelegates()
        tableView.setUpHeader()
    }

    private func setUpViews() {
        title = "Мои Дела"
        view.backgroundColor = .specialBackground
        view.addSubview(tableView)
    }
    
    private func setUpDelegates() {
        tableView.mainViewControllerDelegate = self
    }
    
    deinit {
        print("Gone")
    }

}

extension MainViewController: TableViewMainProtocol {
    
    func getViewModel() -> TableViewViewModelType? {
        return mainViewModel
    }
    
    func cellTapped(withViewModel viewModel: DetailViewModelType?) {
        let vc = DetailViewController(viewModel: viewModel)
        present(vc, animated: true)
    }
}


extension MainViewController {
    private func setUpConstraints() {
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
