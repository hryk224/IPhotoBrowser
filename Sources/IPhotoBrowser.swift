//
//  IPhotoBrowser.swift
//  IPhotoBrowser
//
//  Created by yoshida hiroyuki on 2017/02/16.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import UIKit
import Photos

enum IPhotoBrowserSourceType {
    case image, imageUrl, asset
}

enum SegueType {
    case pushed
    case presented
    var isPushed: Bool { return self == .pushed }
    var isPresented: Bool { return self == .presented }
}

open class IPhotoBrowser: UIViewController {
    public var images: [UIImage] = []
    public var imageUrls: [URL] = []
    public var assets: [PHAsset] = []
    public var index: Int = 0 {
        didSet {
            guard index != oldValue else { return }
            delegate?.iPhotoBrowser(self, didChange: index)
            guard segueType.isPushed else { return }
            setScreenshot()
        }
    }
    public lazy var containerView: UIView = {
        return self.makeContainerView()
    }()
    public var overlayView: UIView?
    public var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = .clear
            collectionView.isPagingEnabled = true
            collectionView.minimumZoomScale = 1
            collectionView.maximumZoomScale = 8
            collectionView.register(IPhotoBrowserCollectionViewCell.self, forCellWithReuseIdentifier: IPhotoBrowserCollectionViewCell.identifier)
            collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: false)
        }
    }
    fileprivate(set) var imageView: UIImageView?
    fileprivate var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    fileprivate var navigationBarHeight: CGFloat {
        return navigationController?.navigationBar.frame.height ?? 0
    }
    // MARK: -  Initialized
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    public convenience init(images: [UIImage], start index:Int) {
        self.init(nibName: nil, bundle: nil)
        self.images = images
        self.index = index
        self.transitioningDelegate = self
        self.modalPresentationStyle = .overCurrentContext
        self.modalPresentationCapturesStatusBarAppearance = true
        self.sourceType = .image
    }
    public convenience init(imageUrls: [URL], start index:Int) {
        self.init(nibName: nil, bundle: nil)
        self.imageUrls = imageUrls
        self.index = index
        self.transitioningDelegate = self
        self.modalPresentationStyle = .overCurrentContext
        self.modalPresentationCapturesStatusBarAppearance = true
        self.sourceType = .imageUrl
    }
    public convenience init(assets: [PHAsset], start index:Int) {
        self.init(nibName: nil, bundle: nil)
        self.assets = assets
        self.index = index
        self.transitioningDelegate = self
        self.modalPresentationStyle = .overCurrentContext
        self.modalPresentationCapturesStatusBarAppearance = true
        self.sourceType = .asset
    }
    // Private property
    var segueType: SegueType = .pushed
    fileprivate var sourceType: IPhotoBrowserSourceType = .image
    fileprivate var backgroundColor: UIColor = .black // Default
    open override func loadView() {
        super.loadView()
        view.backgroundColor = .clear
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard segueType.isPushed else { return }
        setScreenshot()
    }
    // Open property
    open weak var delegate: IPhotoBrowserDelegate?
    open func configure(backgroundColor: UIColor) {
        overlayView?.backgroundColor = backgroundColor
        self.backgroundColor = backgroundColor
    }
}

// MARK: - IPhotoBrowserAnimatedTransitionProtocol
extension IPhotoBrowser: IPhotoBrowserAnimatedTransitionProtocol {
    var currentIndex: Int {
        return Int(collectionView.contentOffset.x / collectionView.frame.size.width)
    }
    public var iPhotoBrowserSelectedImageViewCopy: UIImageView? {
        let indexPath = IndexPath(item: currentIndex, section: 0)
        guard let cell = collectionView.cellForItem(at: indexPath) as? IPhotoBrowserCollectionViewCell else { return nil }
        let sourceImageView = UIImageView(image: cell.imageView.image)
        sourceImageView.contentMode = cell.imageView.contentMode
        sourceImageView.clipsToBounds = true
        sourceImageView.frame = cell.imageView.frame
        return sourceImageView
    }
    public var iPhotoBrowserDestinationImageViewSize: CGSize? {
        var size = collectionView.bounds.size
        let minimumLineSpacing: CGFloat = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? 0
        size.width -= minimumLineSpacing
        return size
    }
    public var iPhotoBrowserDestinationImageViewCenter: CGPoint? {
        let minimumLineSpacing: CGFloat = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? 0
        var center = collectionView.center
        center.x -= (minimumLineSpacing / 2)
        guard let sectionInset = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset else {
            return center
        }
        center.y += (sectionInset.top / 2)
        return center
    }
    public func iPhotoBrowserTransitionWillBegin() {
        collectionView.isHidden = true
    }
    public func iPhotoBrowserTransitionDidEnded() {
        collectionView.isHidden = false
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension IPhotoBrowser: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sourceType {
        case .image:
            return images.count
        case .imageUrl:
            return imageUrls.count
        case .asset:
            return assets.count
        }
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IPhotoBrowserCollectionViewCell.identifier, for: indexPath) as! IPhotoBrowserCollectionViewCell
        cell.delegate = self
        switch sourceType {
        case .image:
            cell.configure(image: images[indexPath.item])
        case .imageUrl:
            cell.configure(imageUrl: imageUrls[indexPath.item], indexPath: indexPath)
        case .asset:
            cell.configure(asset: assets[indexPath.item])
        }
        return cell
    }
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard index != currentIndex else { return }
        index = currentIndex
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard index != currentIndex else { return }
        index = currentIndex
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate && index != currentIndex else { return }
        index = currentIndex
    }
}

// MARK: - IPhotoBrowserCollectionViewCellDelegate
extension IPhotoBrowser: IPhotoBrowserCollectionViewCellDelegate {
    func cellImageViewDidChanging(_ cell: IPhotoBrowserCollectionViewCell) {
        collectionView.isScrollEnabled = false
    }
    func cellImageViewDidDragging(_ cell: IPhotoBrowserCollectionViewCell, ratio: CGFloat) {
        overlayView?.alpha = min(1, max(0, (1 - ratio)))
        switch segueType {
        case .presented:
            delegate?.iPhotoBrowserDidDismissing?(self)
        case .pushed:
            delegate?.iPhotoBrowserDidPop?(self)
        }
    }
    func cellImageViewDidEndDragging(_ cell: IPhotoBrowserCollectionViewCell, isClosed: Bool) {
        guard isClosed else {
            collectionView.isScrollEnabled = true
            return
        }
        switch segueType {
        case .presented:
            dismiss(animated: true, completion: nil)
        case .pushed:
            _ = navigationController?.popViewController(animated: true)
        }
    }
    func cellImageViewDidEndCancelAnimation(_ cell: IPhotoBrowserCollectionViewCell) {
        collectionView.isScrollEnabled = true
        switch segueType {
        case .presented:
            delegate?.iPhotoBrowserDidCanceledDismiss?(self)
        case .pushed:
            delegate?.iPhotoBrowserDidCanceledPop?(self)
        }
    }
    func cellImageViewDidZooming(_ cell: IPhotoBrowserCollectionViewCell, isZooming: Bool) {
        navigationItem.hidesBackButton = isZooming
        collectionView.isScrollEnabled = !isZooming
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension IPhotoBrowser: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = IPhotoBrowserAnimatedTransition(isPresent: true)
        animator.sourceProtocol = source as? IPhotoBrowserAnimatedTransitionProtocol
        animator.destinationProtocol = presented as? IPhotoBrowserAnimatedTransitionProtocol
        (presented as? IPhotoBrowser)?.segueType = .presented
        return animator
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = IPhotoBrowserAnimatedTransition(isPresent: false)
        animator.sourceProtocol = dismissed as? IPhotoBrowserAnimatedTransitionProtocol
        if let destinationProtocol = presentingViewController as? IPhotoBrowserAnimatedTransitionProtocol {
            animator.destinationProtocol = destinationProtocol
        } else if let navigationController = presentingViewController as? UINavigationController {
            animator.destinationProtocol = navigationController.topViewController as? IPhotoBrowserAnimatedTransitionProtocol
        }
        return animator
    }
}

// MARK: - Private
private extension IPhotoBrowser {
    var flexibleAutoresizing: UIViewAutoresizing {
        return [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
    }
    func setUp() {
        if segueType.isPushed {
            let imageView = self.makeImageView()
            containerView.addSubview(imageView)
            self.imageView = imageView
        }
        let overlayView = self.makeOverlayView()
        containerView.addSubview(overlayView)
        self.overlayView = overlayView
        let layout = IPhotoBrowserCollectionViewFlowLayout()
        var bounds = containerView.bounds
        layout.minimumLineSpacing = 20
        layout.itemSize = bounds.size
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        bounds.size.width += layout.minimumLineSpacing
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = self.flexibleAutoresizing
        containerView.addSubview(collectionView)
        self.collectionView = collectionView
        view.addSubview(containerView)
    }
    func makeContainerView() -> UIView {
        let containerView = UIView(frame: self.view.bounds)
        containerView.autoresizingMask = self.flexibleAutoresizing
        containerView.backgroundColor = .clear
        return containerView
    }
    func makeOverlayView() -> UIView {
        let overlayView = UIView(frame: self.view.bounds)
        overlayView.autoresizingMask = self.flexibleAutoresizing
        overlayView.backgroundColor = backgroundColor
        return overlayView
    }
    func makeImageView() -> UIImageView {
        let imageView = UIImageView(frame: self.view.bounds)
        let topInset = navigationBarHeight + statusBarHeight
        imageView.frame.origin.y += topInset
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.autoresizingMask = self.flexibleAutoresizing
        imageView.isUserInteractionEnabled = false
        return imageView
    }
    func setScreenshot() {
        guard let navigationController = navigationController else { return }
        guard navigationController.viewControllers.count - 2 >= 0 else { return }
        let sourceVC = navigationController.viewControllers[navigationController.viewControllers.count - 2] as? IPhotoBrowserDelegate
        let image = sourceVC?.iPhotoBrowserMakeViewScreenshotIfNeeded?(self)
        imageView?.image = image
    }
}
