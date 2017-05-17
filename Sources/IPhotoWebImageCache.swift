//
//  IPhotoWebImageCache.swift
//  IPhotoBrowser
//
//  Created by yoshida hiroyuki on 2017/02/16.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import UIKit.UIImage
import Foundation.NSCache

open class IPhotoWebImageCache {
    open static let `default` = IPhotoWebImageCache(name: "default")
    init(name: String) {
        let cacheName = "io.github.hryk224.IPhotoBrowserExample.ImageCache.\(name)"
        memoryCache.name = cacheName
        #if !os(macOS) && !os(watchOS)
            NotificationCenter.default.addObserver(self, selector: #selector(clearMemoryCache), name: .UIApplicationDidReceiveMemoryWarning, object: nil)
        #endif
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    let memoryCache = NSCache<NSString, UIImage>()
    open func setImage(image: UIImage, for key: String) {
        memoryCache.setObject(image, forKey: key as NSString)
    }
    open func removeImage(for key: String) {
        memoryCache.removeObject(forKey: key as NSString)
    }
    open func image(for key: String) -> UIImage? {
        return memoryCache.object(forKey: key as NSString)
    }
    @objc open func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
}
