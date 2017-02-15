//
//  WebImageTableViewCell.swift
//  IPhotoBrowserExample
//
//  Created by yoshida hiroyuki on 2017/02/16.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import UIKit.UITableViewCell

final class WebImageTableViewCell: UITableViewCell {
    private static let className: String = "WebImageTableViewCell"
    static var identifier: String {
        return className
    }
    static var nib: UINib {
        return UINib(nibName: className, bundle: Bundle(for: self))
    }
    @IBOutlet weak var webImageView: UIImageView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    private var imageUrl: URL?
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        webImageView.image = nil
    }
    func configure(imageUrl: URL) {
        self.imageUrl = imageUrl
        self.indicatorView.isHidden = false
        webImageView.loadWebImage(imageUrl: imageUrl) { [weak self] image, imageUrl in
            guard self?.imageUrl?.absoluteString == imageUrl.absoluteString else { return }
            self?.webImageView.image = image
            self?.indicatorView.isHidden = true
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        }
    }
}
