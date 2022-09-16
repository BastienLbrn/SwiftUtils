//
//  Variable.swift
//  SwiftUtils
//
//  Created by Bastien Lebrun on 22/05/2022.
//

import Foundation

class Variable<Value> {

    var value: Value { didSet { dispatchUpdate() } }
    var onUpdate: ((Value) -> Void)? { didSet { dispatchUpdate() } }

    init(_ value: Value, _ onUpdate: ((Value) -> Void)? = nil) {
        self.value = value
        self.onUpdate = onUpdate
        dispatchUpdate()
    }

    private func dispatchUpdate() {
        DispatchQueue.main.async {
            self.onUpdate?(self.value)
        }
    }

}
