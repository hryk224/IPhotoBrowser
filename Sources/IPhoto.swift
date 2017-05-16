//
//  IPhoto.swift
//  IPhotoBrowser
//
//  Created by hiroyuki yoshida on 2017/02/24.
//
//

import UIKit
import Photos

public struct IPhoto {
    public let image: UIImage?
    public let imageUrl: URL?
    public let asset: PHAsset?
    public let title: String?
    public let description: String?
    var sourceType: IPhotoBrowserSourceType? {
        if image != nil {
            return .image
        } else if imageUrl != nil {
            return .imageUrl
        } else if asset != nil {
            return .asset
        }
        return nil
    }
    public init(image: UIImage,
                title: String? = nil,
                description: String? = nil) {
        self.init(image: image,
                  imageUrl: nil,
                  asset: nil,
                  title: title,
                  description: description)
    }
    public init(imageUrl: URL,
                title: String? = nil,
                description: String? = nil) {
        self.init(image: nil,
                  imageUrl: imageUrl,
                  asset: nil,
                  title: title,
                  description: description)
    }
    public init(asset: PHAsset,
                title: String? = nil,
                description: String? = nil) {
        self.init(image: nil,
                  imageUrl: nil,
                  asset: asset,
                  title: title,
                  description: description)
    }
    private init(image: UIImage?,
                 imageUrl: URL?,
                 asset: PHAsset?,
                 title: String?,
                 description: String?) {
        self.image = image
        self.imageUrl = imageUrl
        self.asset = asset
        self.title = title
        self.description = description
    }
}
