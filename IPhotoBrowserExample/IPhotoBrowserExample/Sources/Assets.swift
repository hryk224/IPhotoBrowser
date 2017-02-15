//
//  Assets.swift
//  IPhotoBrowserExample
//
//  Created by hryk224 on 2017/02/15.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import UIKit.UIImage
import UIKit.UIColor

struct Assets {
    struct Image {
        static let share: Assets.Image = Image()
        let objects: [UIImage]
        private let countableRange: CountableRange<Int> = 0..<36
        var count: Int {
            return countableRange.count
        }
        private init() {
            objects = countableRange.map { String($0) }.flatMap { UIImage(named: $0) }
        }
    }
    struct ImageURL {
        static let share: Assets.ImageURL = ImageURL()
        let objects: [URL]
        private let countableRange: CountableRange<Int> = 1..<100
        var count: Int {
            return countableRange.count
        }
        private init() {
            objects = countableRange
//                .map { "https://github.com/hryk224/IPhotoBrowser/wiki/images/0" + String($0) + ".jpg" }
                .map { "https://dummyimage.com/200x200/\(UIColor.random.toHexString)&text=" + String($0) }
                .flatMap { URL(string: $0) }
        }
    }
}

private extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        let trans: CGFloat = min(1, max(0, transparency))
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }
    static var random: UIColor {
        let r = Int(arc4random_uniform(255))
        let g = Int(arc4random_uniform(255))
        let b = Int(arc4random_uniform(255))
        return UIColor(red: r, green: g, blue: b)
    }
    var toHexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "%02X%02X%02X", Int(red * 0xff), Int(green * 0xff), Int(blue * 0xff))
    }
}
