//
//  IPhotoNavigationItem.swift
//  IPhotoBrowser
//
//  Created by hiroyuki yoshida on 2017/02/24.
//
//

import UIKit

final class IPhotoNavigationItem: UINavigationItem {
    convenience init() {
        self.init(title: "")
    }
    override init(title: String) {
        super.init(title: title)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var tintColor: UIColor? {
        didSet {
            titleLabel?.textColor = tintColor
        }
    }
    var titleLabel: UILabel? = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    func configure() {
        titleView = titleLabel
    }
    override var title: String? {
        set {
            titleLabel?.text = newValue
            titleLabel?.sizeToFit()
        }
        get { return titleLabel?.text }
    }
}
