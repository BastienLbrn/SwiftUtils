//
//  CarouselAccessibilityElement.swift
//
//  Created by Lebrun Bastien on 14/01/2022.
//

import UIKit

protocol CarouselAccessibilityElementDelegate: AnyObject {

    func accessibilityScrollForward()
    func accessibilityScrollBackward()
    
    var accessibilityCurrentValue: String? { get }

}

final class CarouselAccessibilityElement: UIAccessibilityElement {
    
    weak var delegate: CarouselAccessibilityElementDelegate?
    
    override init(accessibilityContainer container: Any) {
        super.init(accessibilityContainer: container)
    }
    
    /// This tells VoiceOver that our element will support the increment and decrement callbacks.
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return .adjustable
        }
        set {
            super.accessibilityTraits = newValue
        }
    }
    
    override var accessibilityValue: String? {
        get {
            delegate?.accessibilityCurrentValue
        }
        set {
            super.accessibilityValue = newValue
        }
    }

    /// Overriding the following two methods allows the user to perform increment and decrement actions
    /// (done by swiping up or down).
    override func accessibilityIncrement() {
        // This causes the picker to move forward one if the user swipes up.
        delegate?.accessibilityScrollForward()
    }
    
    override func accessibilityDecrement() {
        // This causes the picker to move back one if the user swipes down.
        delegate?.accessibilityScrollBackward()
    }
    
}
