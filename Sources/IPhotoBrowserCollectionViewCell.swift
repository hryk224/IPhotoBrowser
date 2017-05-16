//
//  IPhotoBrowserCollectionViewCell.swift
//  IPhotoBrowser
//
//  Created by yoshida hiroyuki on 2017/02/16.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import UIKit.UICollectionViewCell
import Photos

protocol IPhotoBrowserCollectionViewCellDelegate: class {
    func cellImageViewWillBeginDragging(_ cell: IPhotoBrowserCollectionViewCell)
    func cellImageViewDidChanging(_ cell: IPhotoBrowserCollectionViewCell)
    func cellImageViewDidDragging(_ cell: IPhotoBrowserCollectionViewCell, ratio: CGFloat)
    func cellImageViewDidEndDragging(_ cell: IPhotoBrowserCollectionViewCell, isClosed: Bool)
    func cellImageViewDidEndCancelAnimation(_ cell: IPhotoBrowserCollectionViewCell)
    func cellImageViewDidZooming(_ cell: IPhotoBrowserCollectionViewCell, isZooming: Bool)
}

class IPhotoBrowserCollectionViewCell: UICollectionViewCell {
    private static let className: String = "IPhotoBrowserCollectionViewCell"
    static var identifier: String {
        return className
    }
    fileprivate(set) lazy var scrollView: UIScrollView = {
        return self.makeScrollView()
    }()
    private func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.backgroundColor = .clear
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 8
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
        scrollView.delegate = self
        return scrollView
    }
    fileprivate(set) lazy var imageView: UIImageView = {
        return self.makeImageView()
    }()
    private func makeImageView() -> UIImageView {
        let imageView = UIImageView(frame: self.scrollView.bounds)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
        imageView.isUserInteractionEnabled = true
        self.panGestureRecognizer.addTarget(self, action: #selector(IPhotoBrowserCollectionViewCell.handleGestureImageDragging(_:)))
        self.panGestureRecognizer.delegate = self
        imageView.addGestureRecognizer(self.panGestureRecognizer)
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(IPhotoBrowserCollectionViewCell.handleGestureImageDoubleTap))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGestureRecognizer)
        return imageView
    }
    fileprivate(set) lazy var descriptionLabel: UILabel = {
        return self.makeDescriptionLabel()
    }()
    private func makeDescriptionLabel() -> UILabel {
        let label = PaddingLabel(padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        itemViews.append(label)
        return label
    }
    private var imageSize: CGSize {
        let scale = UIScreen.main.scale
        let screenWidth = UIScreen.main.bounds.width
        return CGSize(width: screenWidth * scale, height: screenWidth * scale)
    }
    private var imageRequestOptions: PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        return options
    }
    fileprivate var originalCenter: CGPoint {
        return CGPoint(x: frame.width / 2, y: frame.height / 2)
    }
    fileprivate let panGestureRecognizer = UIPanGestureRecognizer()
    fileprivate var indexPath: IndexPath?
    fileprivate var itemViews: [UIView] = []
    weak var delegate: IPhotoBrowserCollectionViewCellDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    func configure() {
        backgroundColor = .clear
        clipsToBounds = true
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = true
        addSubviews()
        addConstraints()
    }
    func addSubviews() {
        scrollView.addSubview(imageView)
        contentView.addSubview(scrollView)
        contentView.addSubview(descriptionLabel)        
    }
    func addConstraints() {
        let bottomConstraint = NSLayoutConstraint(item: descriptionLabel,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: contentView,
                                                  attribute: .bottom,
                                                  multiplier: 1,
                                                  constant: 0)
        let rightConstraint = NSLayoutConstraint(item: descriptionLabel,
                                                 attribute: .right,
                                                 relatedBy: .equal,
                                                 toItem: contentView,
                                                 attribute: .right,
                                                 multiplier: 1,
                                                 constant: 0)
        let leftConstraint = NSLayoutConstraint(item: descriptionLabel,
                                                attribute: .left,
                                                relatedBy: .equal,
                                                toItem: contentView,
                                                attribute: .left,
                                                multiplier: 1,
                                                constant: 0)
        let heightConstraint = NSLayoutConstraint(item: descriptionLabel,
                                                  attribute: .height,
                                                  relatedBy: .lessThanOrEqual,
                                                  toItem: nil,
                                                  attribute: .height,
                                                  multiplier: 1,
                                                  constant: 104)
        contentView.addConstraints([bottomConstraint, rightConstraint, leftConstraint, heightConstraint])
    }
    func setUp(description textColor: UIColor, backgroundColor: UIColor) {
        descriptionLabel.textColor = textColor
        descriptionLabel.backgroundColor = backgroundColor.withAlphaComponent(0.5)
    }
    func configure(photo: IPhoto, indexPath: IndexPath) {
        guard let sourceType = photo.sourceType else {
            return
        }
        descriptionLabel.text = photo.description
        showDescriptionLabel(photo.description != nil)
        switch sourceType {
        case .image:
            configure(image: photo.image)
        case .imageUrl:
            configure(imageUrl: photo.imageUrl, indexPath: indexPath)
        case .asset:
            guard let asset = photo.asset else {
                return
            }
            configure(asset: asset)
        default:
            break
        }
    }
    func configure(image: UIImage?) {
        imageView.image = image
        setNeedsLayout()
        layoutIfNeeded()
    }
    func configure(imageUrl: URL?, indexPath: IndexPath) {
        guard let imageUrl = imageUrl else {
            imageView.image = nil
            return
        }
        self.indexPath = indexPath
        imageView.loadWebImage(imageUrl: imageUrl) { [weak self] image, imageUrl in
            guard self?.indexPath?.item == indexPath.item else { return }
            self?.imageView.image = image
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        }
    }
    func configure(asset: PHAsset) {
        asset.fetchImage(targetSize: imageSize, options: imageRequestOptions) { [weak self] image in
            self?.imageView.image = image
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        }
    }
    func showDescriptionLabel(_ isShown: Bool) {
        guard descriptionLabel.alpha != (isShown ? 1: 0) else { return }
        let animations: (() -> Void) = {
            self.descriptionLabel.alpha = isShown ? 1 : 0
        }
        UIView.animate(withDuration: 0.15, delay: isShown ? 0.15 : 0, options: .curveEaseInOut, animations: animations, completion: nil)
    }
}

// MARK: - Private
private extension IPhotoBrowserCollectionViewCell {
    dynamic func handleGestureImageDragging(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        let point = gestureRecognizer.translation(in: view)
        switch gestureRecognizer.state {
        case .began:
            delegate?.cellImageViewWillBeginDragging(self)
        case .changed:
            view.center.x += point.x
            view.center.y += point.y
            gestureRecognizer.setTranslation(.zero, in: view)
            let move: CGFloat = abs(originalCenter.y - view.center.y)
            let scale: CGFloat = min(1, max(0.85, 1 - (move / 1000)))
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
            delegate?.cellImageViewDidChanging(self)
            showItemViews(false)
        case .ended, .cancelled:
            let isClosed: Bool
            if abs(originalCenter.y - view.center.y) > 70 {
                isClosed = true
            } else {
                let animations: (() -> Void) = {
                    view.center = self.originalCenter
                    view.transform = .identity
                }
                UIView.perform(.delete, on: [], options: [], animations: animations) { [weak self] finished in
                    guard let weakSelf = self, finished else { return }
                    self?.delegate?.cellImageViewDidEndCancelAnimation(weakSelf)
                    self?.showItemViews(true)
                }
                isClosed = false
            }
            delegate?.cellImageViewDidEndDragging(self, isClosed: isClosed)
        default:
            break
        }
        let ratio = fabs((view.center.y - (originalCenter.y))  / ((originalCenter.y)))
        delegate?.cellImageViewDidDragging(self, ratio: ratio)
    }
    dynamic func handleGestureImageDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard scrollView.minimumZoomScale == scrollView.zoomScale else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            return
        }
        let zoomRect = self.zoomRect(for: scrollView.zoomScale * 3, center: gestureRecognizer.location(in: gestureRecognizer.view))
        scrollView.zoom(to: zoomRect, animated: true)
    }
    func showItemViews(_ isShown: Bool) {
        itemViews.filter { $0.alpha != (isShown ? 1 : 0) }.forEach { itemView in
            let animations: (() -> Void) = {
                itemView.alpha = isShown ? 1 : 0
            }
            UIView.animate(withDuration: 0.15, delay: isShown ? 0.15 : 0, options: .curveEaseInOut, animations: animations, completion: nil)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension IPhotoBrowserCollectionViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let isZooming: Bool = scrollView.minimumZoomScale != scrollView.zoomScale
        panGestureRecognizer.isEnabled = !isZooming
        delegate?.cellImageViewDidZooming(self, isZooming: isZooming)
        showItemViews(!isZooming)
        guard scrollView.zoomScale > scrollView.minimumZoomScale else {
            scrollView.contentInset = .zero
            return
        }
        guard let image = imageView.image else { return }
        let ratioW = imageView.frame.width / image.size.width
        let ratioH = imageView.frame.height / image.size.height
        let ratio = ratioH > ratioW ? ratioW : ratioH
        let newWidth = image.size.width * ratio
        let newHeight = image.size.height * ratio
        let leftAndRight: CGFloat
        if newWidth * scrollView.zoomScale > imageView.frame.width {
            leftAndRight = (newWidth - imageView.frame.width) / 2
        } else {
            leftAndRight = (scrollView.frame.width - scrollView.contentSize.width) / 2
        }
        let topAndBottom: CGFloat
        if newHeight * scrollView.zoomScale > imageView.frame.height {
            topAndBottom = (newHeight - imageView.frame.height) / 2
        } else {
            topAndBottom = (scrollView.frame.height - scrollView.contentSize.height) / 2
        }
        scrollView.contentInset = UIEdgeInsets(top: topAndBottom, left: leftAndRight, bottom: topAndBottom, right: leftAndRight)
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let isZooming: Bool = scrollView.minimumZoomScale != scrollView.zoomScale
        panGestureRecognizer.isEnabled = !isZooming
        delegate?.cellImageViewDidZooming(self, isZooming: isZooming)
        scrollView.contentSize = CGSize(
            width: imageView.frame.width,
            height: imageView.frame.height
        )
    }
    func zoomRect(for scale:CGFloat, center: CGPoint) -> CGRect {
        let size: CGSize = CGSize(
            width: scrollView.frame.width / scale,
            height: scrollView.frame.height / scale
        )
        let origin: CGPoint = CGPoint(
            x: center.x - size.width / 2.0,
            y: center.y - size.height / 2.0
        )
        return CGRect(origin: origin, size: size)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension IPhotoBrowserCollectionViewCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer, let gestureImageView = gestureRecognizer.view else { return true }
        let velocity = gestureRecognizer.translation(in: gestureImageView)
        return fabs(velocity.y) > fabs(velocity.x)
    }
}

final class PaddingLabel: UILabel {
    var padding: UIEdgeInsets = .zero
    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }
    var paddingSize: CGSize {
        return CGSize(width: padding.left + padding.right, height: padding.top + padding.bottom)
    }
    override func drawText(in rect: CGRect) {
        let newRect = UIEdgeInsetsInsetRect(rect, padding)
        super.drawText(in: newRect)
    }
    override var intrinsicContentSize: CGSize {
        let intrinsicContentSize = super.intrinsicContentSize
        return CGSize(width: intrinsicContentSize.width + paddingSize.width, height: intrinsicContentSize.height + paddingSize.height)
    }
}
