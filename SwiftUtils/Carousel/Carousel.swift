//
//  Carousel.swift
//
//  Created by Lebrun Bastien on 14/01/2022.
//

import UIKit

// U: view model type. T: collection view cell type.
final class Carousel<U: Equatable, T: CarouselCell<U>>: UIViewController,
                                                        UICollectionViewDelegate,
                                                        UICollectionViewDataSource,
                                                        UICollectionViewDelegateFlowLayout,
                                                        CarouselAccessibilityElementDelegate {
    
    private let sectionIndex = 0
    
    // MARK: picker properties
    private let config: CarouselConfig<U>
    var currentSelectedItemIndex: Int? {
        containerView.collectionView.indexPathsForSelectedItems?.first?.item
    }
    private var items: [CarouselItem<U>] = []
    
    // MARK: Views
    
    private let containerView: CarouselContainerView<T>
    
    private lazy var selectionContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = config.selectionContainerConfig.backgroundColor
        view.cornerRadius = config.selectionContainerConfig.cornerRadius
        return view
    }()
    
    init(configuration: CarouselConfig<U>) {
        self.config = configuration
        self.containerView = CarouselContainerView<T>()
       
        super.init(nibName: nil, bundle: nil)
        
        self.containerView.setup(itemInterSpacing: configuration.itemInterSpacing)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = config.clipToBounds
        
        containerView.collectionView.delegate = self
        containerView.collectionView.dataSource = self

        setupViewsAndConstraints()
        setupAccessibility()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerView.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Setup

    func setItems(items: [CarouselItem<U>], keepingSelectedItem: Bool = true) {
        let newSelectedItemIndex: Int?
        
        if keepingSelectedItem {
            // Try to keep selected item.
            newSelectedItemIndex = currentSelectedItemIndex.flatMap {
                guard items.indices.contains($0) else {
                    return nil
                }
                
                let currentSelectedItem = items[$0]
                return items.firstIndex(where: { item in
                    item.value == currentSelectedItem.value
                })
            }
        } else {
            newSelectedItemIndex = nil
        }
        
        self.items = items
        
        containerView.collectionView.reloadData()
        
        // Re-select previously selected index
        if let newSelectedItemIndex = newSelectedItemIndex {
            collectionViewSelectItem(at: newSelectedItemIndex)
        }
    }
    
    // MARK: - Communication

    func selectItem(at index: Int?,
                    triggeringReaction: Bool = false,
                    animated: Bool = true) {
        guard let indexToSelect: Int = index ?? currentSelectedItemIndex ?? items.firstIndex(where: { $0.selectable }) else {
            return
        }
        
        guard items.indices.contains(indexToSelect) else {  // Protection
            return
        }
        
        guard currentSelectedItemIndex != indexToSelect else {
            // Event the good index is selected, we must trigger the reaction in case it is asked for
            if triggeringReaction {
                config.selectionHandler(items[indexToSelect])
            }
            return
        }
        
        collectionViewSelectItem(at: indexToSelect, animated: animated)

        if triggeringReaction {
            config.selectionHandler(items[indexToSelect])
        }
    }
    
    // MARK: - UI
    private func setupViewsAndConstraints() {
        if config.selectionContainerConfig.isVisible {
            // Selection container (blue background)
            
            view.addSubview(selectionContainerView)
            
            selectionContainerView.translatesAutoresizingMaskIntoConstraints = false

            let selectionContainerWidth = view.frame.size.width / CGFloat(config.visibleCellCount)
            selectionContainerView.widthAnchor.constraint(equalToConstant: selectionContainerWidth).isActive = true
            selectionContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            selectionContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            selectionContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
            selectionContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        }

        // Collection view's container
        view.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func setupAccessibility() {
        containerView.carouselAccessibilityElement.delegate = self
        accessibilityElements = [containerView]
    }

    var accessibilityIdentifier: String? {
        get {
            containerView.accessibilityIdentifier
        }
        set {
            containerView.accessibilityIdentifier = newValue
        }
    }

    override var accessibilityLabel: String? {
        get {
            containerView.accessibilityLabel
        }
        set {
            containerView.accessibilityLabel = newValue
        }
    }
    
    override var accessibilityHint: String? {
        get {
            containerView.accessibilityHint
        }
        set {
            containerView.accessibilityHint = newValue
        }
    }
    
    private func findCenteredIndexPath() -> IndexPath? {
        let collectionViewCenter = view.convert(containerView.collectionView.center, to: containerView.collectionView)
        if let indexPath = containerView.collectionView.indexPathForItem(at: collectionViewCenter) {
            return indexPath
        }
        
        let rightBoundPoint = CGPoint(x: collectionViewCenter.x + config.itemInterSpacing / 2, y: collectionViewCenter.y)
        if let indexPath = containerView.collectionView.indexPathForItem(at: rightBoundPoint) {
            return indexPath
        }
        
        let leftBoundPoint = CGPoint(x: collectionViewCenter.x - config.itemInterSpacing / 2, y: collectionViewCenter.y)
        if let indexPath = containerView.collectionView.indexPathForItem(at: leftBoundPoint) {
            return indexPath
        }

        return nil
    }
    
    // MARK: - Collection Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: T = collectionView.dequeueCell(for: indexPath) else {
            return UICollectionViewCell()
        }

        cell.setup(item: items[indexPath.item])
        
        return cell
    }
    
    // MARK: - Collection Flow Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.frame.size.width / CGFloat(config.visibleCellCount) - config.itemPadding.left - config.itemPadding.right

        let itemHeight = collectionView.frame.height - config.itemPadding.top - config.itemPadding.bottom

        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        config.insets
    }

    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if UIAccessibility.isVoiceOverRunning {
            config.voiceOverHighlightHandler(items[indexPath.item])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = items[indexPath.item]
        return item.selectable
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        if items.indices.contains(indexPath.item) {  // Protection
            let item = items[indexPath.item]

            config.scrollHandler(item)
            config.selectionHandler(item)
            config.tapHandler(item)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        config.didScrollHandler()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let centeredIndex = findCenteredIndexPath() {
            scrollOrSelectItem(at: centeredIndex)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate, let centeredIndex = findCenteredIndexPath() {
            scrollOrSelectItem(at: centeredIndex)
        }
    }
    
    private func scrollOrSelectItem(at indexPath: IndexPath) {
        guard indexPath.section == sectionIndex else {
            return
        }
        
        let itemIndex = indexPath.item
        
        guard items.indices.contains(itemIndex) else {
            return
        }
        
        let item = items[itemIndex]
        if item.selectable {
            // Item selectable: select item
            collectionViewSelectItem(at: itemIndex, animated: true)
            config.scrollHandler(item)
            config.selectionHandler(item)
        } else {
            // Item not selectable: scroll to item
            let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
            containerView.collectionView.scrollToItem(at: indexPath,
                                                      at: .centeredHorizontally,
                                                      animated: true)
            config.scrollHandler(item)
        }
    }
    
    private func collectionViewSelectItem(at index: Int, animated: Bool = true) {
        let indexPath = IndexPath(item: index, section: sectionIndex)
        containerView.collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: .centeredHorizontally)
    }
    
    // MARK: - CarouselAccessibilityElementDelegate
    
    var currentlyVisibleCellIndex: Int? {
        let pointX = containerView.collectionView.contentOffset.x + containerView.collectionView.center.x
        let point = CGPoint(x: pointX, y: containerView.collectionView.center.y)
        return containerView.collectionView.indexPathForItem(at: point)?.item
    }
    
    func cell(at index: Int) -> T? {
        let indexPath = IndexPath(item: index, section: sectionIndex)
        return containerView.collectionView.cellForItem(at: indexPath) as? T
    }
    
    var currentlyVisibleCell: T? {
        guard let currentlyVisibleCellIndex = currentlyVisibleCellIndex else {
            return nil
        }
        
        return cell(at: currentlyVisibleCellIndex)
    }
    
    private func accessibilityScroll(byIncrementing increment: Int) {
        guard let currentlyVisibleCellIndex = currentlyVisibleCellIndex else {
            return
        }
        
        let indexToScrollOn: Int = currentlyVisibleCellIndex + increment
        let indexPath = IndexPath(item: indexToScrollOn, section: sectionIndex)
        
        scrollOrSelectItem(at: indexPath)
    }
    
    func accessibilityScrollForward() {
        accessibilityScroll(byIncrementing: 1)
    }
    
    func accessibilityScrollBackward() {
        accessibilityScroll(byIncrementing: -1)
    }
    
    var accessibilityCurrentValue: String? {
        guard let currentlyVisibleCellIndex = currentlyVisibleCellIndex,
              items.indices.contains(currentlyVisibleCellIndex) else {
            return nil
        }
    
        return items[currentlyVisibleCellIndex].accessibilityValue
    }

}

class CarouselContainerView<T: UICollectionViewCell>: UIView {
    
    fileprivate var itemInterSpacing: CGFloat = 0
    
    fileprivate let carouselAccessibilityElement: CarouselAccessibilityElement = CarouselAccessibilityElement(accessibilityContainer: self)
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = itemInterSpacing
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = false
        collectionView.allowsMultipleSelection = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
        collectionView.register(cellClass: T.self)
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("CarouselContainerView constructor not implemented.")
    }

    fileprivate func setup(itemInterSpacing: CGFloat) {
        self.itemInterSpacing = itemInterSpacing  // Because used in lazy collectionView.
        
        addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    override var accessibilityLabel: String? {
        get {
            carouselAccessibilityElement.accessibilityLabel
        }
        set {
            carouselAccessibilityElement.accessibilityLabel = newValue
        }
    }
    
    override var accessibilityHint: String? {
        get {
            carouselAccessibilityElement.accessibilityHint
        }
        set {
            carouselAccessibilityElement.accessibilityHint = newValue
        }
    }

    private var _accessibilityElements: [Any]?

    override var accessibilityElements: [Any]? {
        get {
            guard _accessibilityElements == nil else {
                return _accessibilityElements
            }

            carouselAccessibilityElement.accessibilityFrameInContainerSpace = collectionView.frame
            _accessibilityElements = [carouselAccessibilityElement]
            
            return _accessibilityElements
        }
        set {
            _accessibilityElements = newValue
        }
    }

}
