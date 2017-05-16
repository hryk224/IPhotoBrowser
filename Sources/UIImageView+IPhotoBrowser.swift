//
//  UIImageView+IPhotoBrowser.swift
//  IPhotoBrowser
//
//  Created by yoshida hiroyuki on 2017/02/16.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import UIKit.UIImageView

// MARK: - Load web image
extension UIImageView {
    open func loadWebImage(imageUrl: URL, completion: @escaping (UIImage?, URL) -> Void) {
        if let image = IPhotoWebImageCache.default.image(for: imageUrl.absoluteString) {
            completion(image, imageUrl)
            return
        }
        let request = URLRequest(url: imageUrl, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10 * 60)
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: .main)
        session.dataTask(with: request) { data, response, error in
            if let data = data,
                let image = UIImage(data: data),
                error == nil {
                IPhotoWebImageCache.default.removeImage(for: imageUrl.absoluteString)
                IPhotoWebImageCache.default.setImage(image: image, for: imageUrl.absoluteString)
                completion(image, imageUrl)
            } else {
                print("Failed loading image: \(error)")
            }
            }.resume()
    }
}
