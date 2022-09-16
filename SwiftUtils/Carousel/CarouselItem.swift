//
//  CarouselItem.swift
//
//  Created by Lebrun Bastien on 14/01/2022.
//

import Foundation

struct CarouselItem<T: Equatable> {

    let value: T?
    let selectable: Bool
    let accessibilityValue: String?
    
    init(_ value: T? = nil,
         selectable: Bool = true,
         accessibilityValue: String? = nil) {
        self.value = value
        self.selectable = selectable
        self.accessibilityValue = accessibilityValue
    }
    
}
