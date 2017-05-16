//
//  UIView+IPhotoBrowser.swift
//  IPhotoBrowser
//
//  Created by yoshida hiroyuki on 2017/02/20.
//
//

import UIKit.UIView

extension UIView {
    open var screenshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, UIScreen.main.scale);
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func cornerRadiusAnimation(_ from: CGFloat, to: CGFloat, duration: CFTimeInterval) {
        layer.masksToBounds = true
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        layer.add(animation, forKey: "cornerRadius")
        layer.cornerRadius = to
    }
}
