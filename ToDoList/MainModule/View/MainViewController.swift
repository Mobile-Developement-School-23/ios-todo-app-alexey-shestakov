
import UIKit

class MainViewController: UIViewController {
    
    private var mainViewModel: TableViewViewModelType?
    
    private let tableView = TableView()
    
    private var selectedCell: TableViewCell?
    
    private var startingAnimationPoint: CGPoint {
        guard let cellCenterPoint = self.selectedCell?.center,
              let navigationBarheight = self.navigationController?.navigationBar.frame.height,
              let navigationBarYOffset = self.navigationController?.navigationBar.frame.origin.y else {return .zero}
        return CGPoint(
            x: cellCenterPoint.x,
            y: cellCenterPoint.y + navigationBarheight + navigationBarYOffset
        )
    }
    
    lazy var faButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "Remove"), for: .normal)
        button.layer.cornerRadius = 25
        button.addShadowOnView()
        button.addTarget(self, action: #selector(addTask), for: .touchUpInside)
        return button
    }()
    
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
        tableView.setUpFooter()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(tableView)
    }

    private func setUpViews() {
        title = "Мои дела"
        navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 0)
        view.backgroundColor = .specialBackground
        view.addSubview(tableView)
        view.addSubview(faButton)
    }
    
    private func setUpDelegates() {
        tableView.mainViewControllerDelegate = self
    }
    
    @objc func addTask() {
        guard let mainViewModel else {return}
        let detailViewModel = DetailViewModel(dataBase: mainViewModel.returnModel(), index: nil)
        let vc = DetailViewController(viewModel: detailViewModel)
        present(vc, animated: true)
    }
}

extension MainViewController: TableViewMainProtocol {
    
    func getViewModel() -> TableViewViewModelType? {
        return mainViewModel
    }
    
    func cellTapped(withViewModel viewModel: DetailViewModelType?, selectedCell: TableViewCell) {
        self.selectedCell = selectedCell
        let vc = DetailViewController(viewModel: viewModel)
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        present(vc, animated: true)
    }
}

extension MainViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CellAnimator(duration: 0.3,
                            transitionMode: .present,
                            startingPoint: self.startingAnimationPoint)
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CellAnimator(duration: 0.3,
                            transitionMode: .dismiss,
                            startingPoint: CGPoint(x: 0, y: 0))
    }
}

extension MainViewController {
    private func setUpConstraints() {
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            faButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
            faButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            faButton.heightAnchor.constraint(equalToConstant: 50),
            faButton.widthAnchor.constraint(equalToConstant: 50),
        ])
    }
}
