//
//  AssetCollectionViewCell.swift
//  IPhotoBrowserExample
//
//  Created by yoshida hiroyuki on 2017/02/15.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import UIKit.UICollectionViewCell
import Photos

final class AssetCollectionViewCell: UICollectionViewCell {
    private static let className: String = "AssetCollectionViewCell"
    static var identifier: String {
        return className
    }
    static var nib: UINib {
        return UINib(nibName: className, bundle: Bundle(for: self))
    }
    @IBOutlet weak var imageView: UIImageView! {
        didSet { imageView.contentMode = .scaleAspectFill }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    func configure(photo: PHPhoto) {
        photo.fetchImage(type: .thumbnail) { [weak self] image in
            self?.imageView.image = image
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        }
    }
    func configure(image: UIImage?) {
        imageView.image = image
        setNeedsLayout()
        layoutIfNeeded()
    }
}
