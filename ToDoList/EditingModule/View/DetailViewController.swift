//
//  DetailViewController.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 19.06.2023.
//

import UIKit

class DetailViewController: UIViewController, ExtandingTextViewProtocol {
    
    var viewModel: DetailViewModelType?
    
    func getView() -> UIView {
        view
    }
    
    let navigtionBar: UINavigationBar = {
        let nav = UINavigationBar()
        nav.translatesAutoresizingMaskIntoConstraints = false
        nav.backgroundColor = .specialBackground
        return nav
    }()
    
    let textView = ExtandingTextView()
    
    let importanceDeadlineView = ImportanceDeadlineView()
    
    // Chanable parameters
    var keyBoardHeight: CGFloat = 0
    
    var coursorDistanceFromBottom: CGFloat = 0
    
    var rollY: CGFloat = 0
    
    var importanceDeadlineViewHeight = NSLayoutConstraint()
    

    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = .specialBackground
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.tintColor = .lightGray
        button.setTitle("Удалить", for: .normal)
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    
    convenience init(viewModel: DetailViewModelType?) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
        setUpDelegates()
        setUpViews()
        setUpNavigationController()
        setUpConstraints()
        addGesture()
        
        addGesture()
        
        configure()
        layoutForTransition()
    }
    override func viewWillAppear(_: Bool) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification: )),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification: )),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(makeSavingEnable),
                                               name: .editingStarted,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(makeSavingInEnable),
                                               name: .hasNoText,
                                               object: nil)
    }

    override func viewDidDisappear(_: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .editingStarted, object: nil)
        NotificationCenter.default.removeObserver(self, name: .hasNoText, object: nil)
    }
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        layoutForTransition()
        if keyBoardHeight != 0 {
            
        }
    }
    
    @discardableResult
    func layoutForTransition() -> UIDeviceOrientation {
        let orientation = UIDevice.current.orientation
        
        switch orientation {
        case .portrait:
            importanceDeadlineView.isHidden = false
            deleteButton.isHidden = false
        case .portraitUpsideDown:
            importanceDeadlineView.isHidden = false
            deleteButton.isHidden = false
        case .landscapeLeft:
            importanceDeadlineView.isHidden = true
            deleteButton.isHidden = true
        case .landscapeRight:
            importanceDeadlineView.isHidden = true
            deleteButton.isHidden = true
        default:
            break
        }
        return orientation
    }
    
    private func setUpViews() {
        view.backgroundColor = .specialBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(navigtionBar)
        contentView.addSubview(textView)
        contentView.addSubview(importanceDeadlineView)
        contentView.addSubview(deleteButton)
    }
    
    private func configure() {
        guard viewModel?.getIndex() != nil, let text = viewModel?.text, let importance = viewModel?.importance else { return }
        textView.text = text
        importanceDeadlineView.configure(importance: importance, deadLine: viewModel?.deadline)
        deleteButton.isEnabled = true
        deleteButton.tintColor = .red
    }
    
    
    private func setUpDelegates() {
        textView.viewControllerDelegate = self
        importanceDeadlineView.detailViewControllerDelegate = self
    }
    
    @objc private func saveButtonTapped() {
        if viewModel?.getIndex() != nil {
            viewModel?.saveChangesItemToDataBase(text: textView.text, importanceSegment: importanceDeadlineView.segmentedControl.selectedSegmentIndex, deadline: importanceDeadlineView.getDeadlineDate())
            NotificationCenter.default.post(name: .reloadData, object: nil)
        } else {
            viewModel?.saveNewItemToDataBase(text: textView.text,
                                             importanceSegment: importanceDeadlineView.segmentedControl.selectedSegmentIndex,
                                             deadline: importanceDeadlineView.getDeadlineDate())
            NotificationCenter.default.post(name: .reloadData, object: nil)
        }
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func deleteButtonTapped() {
        viewModel?.removeFromDB()
        NotificationCenter.default.post(name: .reloadData, object: nil)
        dismiss(animated: true)
    }
    
    @objc private func makeSavingEnable() {
        if !textView.text.isEmpty {
            navigtionBar.topItem?.rightBarButtonItem?.isEnabled = true
            navigtionBar.topItem?.rightBarButtonItem?.tintColor = .systemBlue
        }
    }
    
    @objc private func makeSavingInEnable() {
        navigtionBar.topItem?.rightBarButtonItem?.isEnabled = false
        deleteButton.isEnabled = false
    }
}


extension DetailViewController: ImportanceDeadlineViewProtocol {
    
    func hideDatePicker(height: CGFloat) {
        importanceDeadlineViewHeight.constant = 140
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func rollScrollViewForDatePicker(height: CGFloat) {
        if importanceDeadlineView.frame.maxY > view.frame.maxY {
            UIView.animate(withDuration: 0.5) {
                self.scrollView.contentOffset = CGPoint(x: 0, y: self.scrollView.contentOffset.y + height)
            }
        }
    }
}







extension DetailViewController {
    private func addGesture() {
        let tapScreen = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapScreen.cancelsTouchesInView = false
        view.addGestureRecognizer(tapScreen)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - TextViewCoursor detection
extension DetailViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyBoardHeight = keyboardSize.height
        textView.getCoursorY(textView: textView)
        rollScrollViewForTextView(coursorDist: coursorDistanceFromBottom)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        keyBoardHeight = 0
    }
    
    func rollScrollViewForTextView(coursorDist: CGFloat) {
        let distanseAboveKeyboard: CGFloat = 30
        if coursorDist < keyBoardHeight + distanseAboveKeyboard {
            rollY = keyBoardHeight - coursorDist + scrollView.contentOffset.y + distanseAboveKeyboard
            scrollView.setContentOffset(CGPoint(x: 0, y: rollY), animated: true)
        } else {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y), animated: true)
        }
    }
}


// MARK: - configure NavigationController
extension DetailViewController {
    private func setUpNavigationController() {

        NSLayoutConstraint.activate([
            navigtionBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigtionBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigtionBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        
        ])
        let title = UINavigationItem(title: "Дело")
        let saveButton = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(saveButtonTapped))
        saveButton.tintColor = UIColor.lightGray
        saveButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)], for: .normal)
        saveButton.isEnabled = false
        
        let cancelButton = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(cancelButtonTapped))
        title.rightBarButtonItem = saveButton
        title.leftBarButtonItem = cancelButton
        
        navigtionBar.setItems([title], animated: true)
    }
}

// MARK: - Constraints
extension DetailViewController {
    private func setUpConstraints() {
        
        importanceDeadlineViewHeight = importanceDeadlineView.heightAnchor.constraint(greaterThanOrEqualToConstant: 140)
        importanceDeadlineViewHeight.isActive = true
        
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo:  view.keyboardLayoutGuide.topAnchor),
            
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            textView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 72),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: textView.minHeight),
            
            importanceDeadlineView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            importanceDeadlineView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            importanceDeadlineView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 28),
            
            deleteButton.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            deleteButton.topAnchor.constraint(equalTo: importanceDeadlineView.bottomAnchor, constant: 28),
            deleteButton.heightAnchor.constraint(equalToConstant: 60),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            
        ])
        
    }
}
