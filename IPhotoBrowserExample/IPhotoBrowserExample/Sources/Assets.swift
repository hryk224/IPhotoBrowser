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
    let image = Image()
    let color = Color()
    struct Image {
        static let share: Assets.Image = Image()
        fileprivate init() {}
        private let countableRange: CountableRange<Int> = 0..<36
        var count: Int {
            return countableRange.count
        }
        var objects: [UIImage] {
            return countableRange.map { String($0) }.flatMap { UIImage(named: $0) }
        }
    }
    struct Color {
        static let share: Assets.Color = Color()
        let objects: [UIColor]
        private let countableRange: CountableRange<Int> = 0..<100
        var count: Int {
            return countableRange.count
        }
        fileprivate init() {
            objects = countableRange.map { _ in Void() }.flatMap { UIColor.random }
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
}
