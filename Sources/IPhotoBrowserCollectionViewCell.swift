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
    func configure(image: UIImage?) {
        imageView.image = image
        setNeedsLayout()
        layoutIfNeeded()
    }
    func configure() {
        backgroundColor = .clear
        clipsToBounds = true
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = true
        scrollView.addSubview(imageView)
        contentView.addSubview(scrollView)
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
}

// MARK: - Private
private extension IPhotoBrowserCollectionViewCell {
    dynamic func handleGestureImageDragging(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        let point = gestureRecognizer.translation(in: view)
        switch gestureRecognizer.state {
        case .began:
            break
        case .changed:
            view.center.x += point.x
            view.center.y += point.y
            gestureRecognizer.setTranslation(.zero, in: view)
            let move: CGFloat = abs(originalCenter.y - view.center.y)
            let scale: CGFloat = min(1, max(0.85, 1 - (move / 1000)))
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
            delegate?.cellImageViewDidChanging(self)
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
