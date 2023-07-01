//
//  ImportanceDeadlineView.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 22.06.2023.
//

import UIKit

protocol ImportanceDeadlineViewProtocol: AnyObject {
    var importanceDeadlineViewHeight: NSLayoutConstraint {get set}
    func hideDatePicker(height: CGFloat)
    func rollScrollViewForDatePicker(height: CGFloat)
}

class ImportanceDeadlineView: UIView {
    
    weak var detailViewControllerDelegate: ImportanceDeadlineViewProtocol?
    
    private let separatorFirst: UIView = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let separatorSecond: UIView = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.isHidden = true
        return view
    }()

    private let importanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Важность"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    lazy var segmentedControl: UISegmentedControl = {
        guard let arrowSegment = UIImage(named: "Arrow"),
              let important = UIImage(named: "Important") else {return UISegmentedControl()}
        let noSegment = "нет"
        let segmentedControl = UISegmentedControl(items: [arrowSegment, noSegment, important])
        segmentedControl.tintColor = .red
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.selectedSegmentTintColor = .systemBlue
        segmentedControl.setTitleTextAttributes([ .foregroundColor: UIColor.black], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()

    private let deadlineLabel: UILabel = {
        let label = UILabel()
        label.text = "Сделать до"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var deadlineButton: UIButton = {
        let button = UIButton(type: .system)
        let dateString = Date().localDate().stringFromDate()
        button.setTitle(dateString, for: .normal)
        button.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    private lazy var deadlineSwitch: UISwitch = {
        let deadlineSwitch = UISwitch()
        deadlineSwitch.isOn = false
        deadlineSwitch.onTintColor = .systemBlue
        deadlineSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        deadlineSwitch.translatesAutoresizingMaskIntoConstraints = false
        return deadlineSwitch
    }()

    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.isHidden = true
        datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date().localDate())
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return datePicker
    }()
    
    
    ///Dinamic constraints
    var datePickerHeightConstraint = NSLayoutConstraint()
    
    var separatorSecondHeight = NSLayoutConstraint()
    
    

    private var stackUpper = UIStackView()

    private var stackLower = UIStackView()

    private var stackVertical = UIStackView()
    
    private var superStack = UIStackView()
    
    private var datePickerSeparatorStack = UIStackView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        
        deadlineButton.setTitle(datePicker.date.stringFromDate(), for: .normal)

        stackUpper = UIStackView(arrangedSubviews: [importanceLabel, segmentedControl],
                                 axis: .horizontal,
                                 spacing: 0)
        
        stackUpper.distribution = .equalSpacing
        
        stackVertical = UIStackView(arrangedSubviews: [deadlineLabel, deadlineButton],
                                    axis: .vertical,
                                    spacing: 10)
        stackVertical.distribution = .equalCentering
        
        stackLower = UIStackView(arrangedSubviews: [stackVertical, deadlineSwitch],
                                 axis: .horizontal,
                                 spacing: 0)
        stackLower.distribution = .equalSpacing
        
        superStack = UIStackView(arrangedSubviews: [stackUpper, separatorFirst, stackLower, separatorSecond],
                                 axis: .vertical,
                                 spacing: 15)
        superStack.distribution = .equalSpacing
        
        
        datePickerSeparatorStack = UIStackView(arrangedSubviews: [separatorSecond, datePicker],
                                               axis: .vertical,
                                               spacing: 15)
        
        addSubview(superStack)
        
        addSubview(datePickerSeparatorStack)
    }
    
    @objc func segmentedControlValueChanged() {
        NotificationCenter.default.post(name: .editingStarted, object: nil)
    }
    
    @objc func switchValueDidChange(_ sender: UISwitch!) {
        NotificationCenter.default.post(name: .editingStarted, object: nil)
        if (sender.isOn){
            deadlineButton.isHidden = false
            deadlineButton.isEnabled = true
        }
        else{
            deadlineButton.isHidden = true
            guard datePicker.isHidden != true else {return}
            UIView.animate(withDuration: 0.5) {
                self.datePicker.isHidden = true
                self.separatorSecond.isHidden = true
                self.detailViewControllerDelegate?.hideDatePicker(height: self.datePicker.frame.height)
            }
        }
    }
    
    @objc private func showDatePicker() {
        ///Считаем расстояние до нижней вьюхи, чтобы все хорошо отображалось
        deadlineButton.isEnabled = false
        UIView.animate(withDuration: 0.5) {
            self.datePicker.isHidden = false
            self.separatorSecond.isHidden = false
        }
        detailViewControllerDelegate?.rollScrollViewForDatePicker(height: datePickerSeparatorStack.frame.height)
    }
    
    @objc private func datePickerValueChanged() {
        NotificationCenter.default.post(name: .editingStarted, object: nil)
        deadlineButton.setTitle(datePicker.date.stringFromDate(), for: .normal)
    }
    
    
    public func configure(importance: Importance, deadLine: Date?) {
        switch importance {
        case .unimportant:
            segmentedControl.selectedSegmentIndex = 0
        case .normal:
            segmentedControl.selectedSegmentIndex = 1
        case .important:
            segmentedControl.selectedSegmentIndex = 2
        }

        if let deadLine {
            deadlineSwitch.isOn = true
            let stringDedline = deadLine.stringFromDate()
            deadlineButton.setTitle(stringDedline, for: .normal)
            deadlineButton.isHidden = false
            datePicker.setDate(deadLine, animated: true)
        }
    }
    
    func getDeadlineDate() -> Date? {
        if deadlineSwitch.isOn {
            return datePicker.date
        }
        return nil
    }
}





extension ImportanceDeadlineView {
    private func setUpConstraints() {
        
        NSLayoutConstraint.activate([
            
            stackLower.heightAnchor.constraint(equalToConstant: 50),
            separatorFirst.heightAnchor.constraint(equalToConstant: 0.5),
            separatorSecond.heightAnchor.constraint(equalToConstant: 0.5),
            
            superStack.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            superStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            superStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            
            datePickerSeparatorStack.topAnchor.constraint(equalTo: superStack.bottomAnchor, constant: 15),
            datePickerSeparatorStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            datePickerSeparatorStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            datePickerSeparatorStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
