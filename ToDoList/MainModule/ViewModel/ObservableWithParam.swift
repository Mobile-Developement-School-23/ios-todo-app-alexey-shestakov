//
//  ObservableWithParam.swift
//  ToDoList
//
//  Created by Alexey Shestakov on 09.07.2023.
//

import Foundation

class ObservableWithParam<T> {
    typealias Listener = (T, Bool) -> ()
    
    var listener: Listener?

    var value: (T, Bool) {
        didSet {
            listener?(value.0, value.1)
        }
    }
    func bind(listener:  @escaping Listener) {
        self.listener = listener
        listener(value.0, value.1)
    }
    
    init(_ value: (T, Bool)) {
        self.value = value
    }
}
