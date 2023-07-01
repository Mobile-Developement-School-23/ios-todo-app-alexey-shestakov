//
//  Observable.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 30.06.2023.
//

import Foundation

class Observable<T> {
    typealias Listener = (T) -> ()
    
    var listener: Listener?

    var value: T {
        didSet {
            listener?(value)
        }
    }
    func bind(listener:  @escaping Listener) {
        self.listener = listener
        listener(value)
    }
    
    init(_ value: T) {
        self.value = value
    }
}
