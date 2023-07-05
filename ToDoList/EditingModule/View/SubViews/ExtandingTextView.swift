//
//  ExtandingTextView.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 19.06.2023.
//

import UIKit

protocol ExtandingTextViewProtocol: AnyObject {
    var coursorDistanceFromBottom: CGFloat {get set}
    func rollScrollViewForTextView(coursorDist: CGFloat)
    func getView() -> UIView
}

class ExtandingTextView: UITextView {
    
    weak var viewControllerDelegate: ExtandingTextViewProtocol?
    
    let minHeight: CGFloat = 120
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: .none)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        font = .systemFont(ofSize: 17)
        textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        backgroundColor = .tertiarySystemBackground
        layer.cornerRadius = 16
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        spellCheckingType = .no
        autocapitalizationType = .none
        isScrollEnabled = false
        sizeToFit()
        delegate = self
    }
}

extension ExtandingTextView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty {
            NotificationCenter.default.post(name: .editingStarted, object: nil)
        } else {
            NotificationCenter.default.post(name: .hasNoText, object: nil)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let viewControllerDelegate else {return}
        getCoursorY(textView: textView)
        viewControllerDelegate.rollScrollViewForTextView(coursorDist: viewControllerDelegate.coursorDistanceFromBottom)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        guard let viewControllerDelegate else {return}
        getCoursorY(textView: textView)
        viewControllerDelegate.rollScrollViewForTextView(coursorDist: viewControllerDelegate.coursorDistanceFromBottom)
    }
    
    func getCoursorY(textView: UITextView) {
        guard let selectedRange = textView.selectedTextRange else {return}
        let caretRect = textView.caretRect(for: selectedRange.end)
        let cursorPosition = CGPoint(x: caretRect.midX, y: caretRect.midY)
        let textViewOrigin = textView.convert(cursorPosition, to: viewControllerDelegate?.getView())
        guard let viewHeight = (viewControllerDelegate?.getView())?.frame.height else {return}
        let distanceFromBottom = viewHeight - textViewOrigin.y
        viewControllerDelegate?.coursorDistanceFromBottom = distanceFromBottom
    }
    
    
}


