//
//  Assets.swift
//  IPhotoBrowserExample
//
//  Created by hryk224 on 2017/02/15.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import UIKit.UIImage
import UIKit.UIColor
import IPhotoBrowser

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
                .map { "https://dummyimage.com/200x200/\(UIColor.random.toHexString)&text=" + String($0) }
                .flatMap { URL(string: $0) }
        }
    }
    struct Photo {
        static let share: Assets.Photo = Photo()
        let objects: [IPhoto]
        private let countableRange: CountableRange<Int> = 1..<36
        var count: Int {
            return countableRange.count
        }
        private init() {
            let count = countableRange.count
            let descriptions: [String] = [
                "It is a sample string. It is a sample string. It is a sample string. It is a sample string. It is a sample string.",
                "サンプル文字列です。サンプル文字列です。サンプル文字列です。サンプル文字列です。サンプル文字列です。",
                "它是一个示例字符串。 它是一个示例字符串。 它是一个示例字符串。 它是一个示例字符串。 它是一个示例字符串。",
                "Quod est a sample nervo. Quod est a sample nervo. Quod est a sample nervo. Quod est a sample nervo. Quod est a sample nervo.",
                "Es ist ein Beispielstring. Es ist ein Beispielstring. Es ist ein Beispielstring. Es ist ein Beispielstring. Es ist ein Beispielstring.",
                "샘플 문자열입니다. 샘플 문자열입니다. 샘플 문자열입니다. 샘플 문자열입니다. 샘플 문자열입니다."
            ]
            objects = countableRange.enumerated()
                .flatMap { ($0 + 1, UIImage(named: String($1))!) }
                .map {
                    IPhoto(image: $1,
                           title: "\($0)/\(count)",
                        description: descriptions[$0 % descriptions.count])
            }
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
