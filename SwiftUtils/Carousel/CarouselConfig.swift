//
//  CarouselConfig.swift
//
//  Created by Lebrun Bastien on 14/01/2022.
//

import UIKit

struct CarouselConfig<T: Equatable> {

    let visibleCellCount: Int
    let clipToBounds: Bool
    let insets: UIEdgeInsets
    let itemPadding: UIEdgeInsets
    let itemInterSpacing: CGFloat
    let selectionContainerConfig: SelectionContainerConfig

    let voiceOverHighlightHandler: (CarouselItem<T>) -> Void
    let didScrollHandler: () -> Void
    let scrollHandler: (CarouselItem<T>) -> Void
    let tapHandler: (CarouselItem<T>) -> Void
    let selectionHandler: (CarouselItem<T>) -> Void
    
    init(visibleCellCount: Int = 5,
         clipToBounds: Bool = true,
         insets: UIEdgeInsets = .zero,
         itemPadding: UIEdgeInsets = .zero,
         itemInterSpacing: CGFloat = 0,
         selectionContainerConfig: SelectionContainerConfig = SelectionContainerConfig(),
         voiceOverHighlightHandler: @escaping (CarouselItem<T>) -> Void = { _ in },
         didScrollHandler: @escaping () -> Void = {},
         scrollHandler: @escaping (CarouselItem<T>) -> Void = { _ in },
         tapHandler: @escaping (CarouselItem<T>) -> Void = { _ in },
         selectionHandler: @escaping (CarouselItem<T>) -> Void = { _ in }) {
        self.visibleCellCount = visibleCellCount
        self.clipToBounds = clipToBounds
        self.insets = insets
        self.itemPadding = itemPadding
        self.itemInterSpacing = itemInterSpacing
        self.selectionContainerConfig = selectionContainerConfig
        self.voiceOverHighlightHandler = voiceOverHighlightHandler
        self.didScrollHandler = didScrollHandler
        self.scrollHandler = scrollHandler
        self.tapHandler = tapHandler
        self.selectionHandler = selectionHandler
    }
    
    struct SelectionContainerConfig {
        
        let isVisible: Bool
        let backgroundColor: UIColor
        let cornerRadius: CGFloat
        
        init(isVisible: Bool = true,
             backgroundColor: UIColor = .tmlPrimaryAction,
             cornerRadius: CGFloat = 7) {
            self.isVisible = isVisible
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
        }
    
    }

}
