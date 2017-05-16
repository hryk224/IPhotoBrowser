//
//  IPhotoBrowserCollectionViewFlowLayout.swift
//  IPhotoBrowser
//
//  Created by yoshida hiroyuki on 2017/02/16.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import UIKit

final class IPhotoBrowserCollectionViewFlowLayout: UICollectionViewFlowLayout {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init() {
        super.init()
        self.minimumInteritemSpacing = 0
        self.scrollDirection = .horizontal
    }
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return super.collectionViewContentSize
        }
        let height = super.collectionViewContentSize.height
        let itemsCount: CGFloat = CGFloat(collectionView.numberOfItems(inSection: 0))
        return CGSize(width: collectionView.bounds.width * itemsCount, height: height)
    }
    override class var layoutAttributesClass: AnyClass { return IPhotoBrowserCollectionViewLayoutAttributes.self }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        return attributes.flatMap { $0.copy() as? UICollectionViewLayoutAttributes }.map { self.transformLayoutAttributes($0) }
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    private func transformLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let collectionView = self.collectionView, let layoutAttributes = attributes as? IPhotoBrowserCollectionViewLayoutAttributes else { return attributes }
        let width = collectionView.frame.width - self.minimumLineSpacing
        let centerX = width / 2
        let offsetX = collectionView.contentOffset.x
        let itemX = layoutAttributes.center.x - offsetX
        let positionX = (itemX - centerX) / width
        if layoutAttributes.imageView == nil {
            layoutAttributes.imageView = (collectionView.cellForItem(at: attributes.indexPath) as? IPhotoBrowserCollectionViewCell)?.imageView
        }
        layoutAttributes.animate(collectionView: collectionView, positionX: positionX)
        return layoutAttributes
    }
}

// MARK: - IPhotoBrowserCollectionViewLayoutAttributes
final class IPhotoBrowserCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    var imageView: UIImageView?
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! IPhotoBrowserCollectionViewLayoutAttributes
        copy.imageView = imageView
        return copy
    }
    func animate(collectionView: UICollectionView, positionX: CGFloat) {
        let speed: CGFloat = 0.2
        if abs(positionX) >= 1 {
            imageView?.transform = .identity
        } else {
            let transitionX = -(frame.width * speed * positionX)
            imageView?.transform = CGAffineTransform(translationX: transitionX, y: 0)
        }
    }
}
