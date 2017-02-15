//
//  Photos.swift
//  IPhotoBrowserExample
//
//  Created by yoshida hiroyuki on 2017/02/15.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import Photos

struct PHAlbumCollection {
    let albums: [PHAlbum]
    init(assetCollections: [PHAssetCollection]) {
        self.albums = assetCollections.map { PHAlbum(assetCollection: $0) }
    }
}

struct PHAlbum {
    var photos: [PHPhoto] = []
    private let assetCollection: PHAssetCollection
    var title: String {
        return assetCollection.localizedTitle ?? ""
    }
    init(assetCollection: PHAssetCollection) {
        self.assetCollection = assetCollection
        let result = PHAsset.fetchAssets(in: assetCollection, options: nil)
        let indexSet = IndexSet(integersIn: 0..<result.count)
        self.photos = result.objects(at: indexSet).flatMap { PHPhoto(asset: $0) }
    }
}

struct PHPhoto {
    enum SizeType {
        case thumbnail
        case displayed
        private var scale: CGFloat {
            return UIScreen.main.scale
        }
        private var screenWidth: CGFloat {
            return UIScreen.main.bounds.width
        }
        var size: CGSize {
            switch self {
            case .thumbnail:
                return CGSize(width: screenWidth / 2 * scale, height: screenWidth / 2 * scale)
            case .displayed:
                return CGSize(width: screenWidth * scale, height: screenWidth * scale)
            }
        }
        var imageRequestOptions: PHImageRequestOptions {
            let options = PHImageRequestOptions()
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = true
            switch self {
            case .thumbnail:
                options.deliveryMode = .fastFormat
                options.resizeMode = .exact
                options.isSynchronous = true
            case .displayed:
                options.deliveryMode = .highQualityFormat
            }
            return options
        }
    }
    let asset: PHAsset
    init(asset: PHAsset) {
        self.asset = asset
    }
    func fetchImage(type: PHPhoto.SizeType, completion: @escaping (UIImage?) -> Void) {
        fetchImage(targetSize: type.size, options: type.imageRequestOptions, completion: completion)
    }
    private func fetchImage(targetSize: CGSize, options: PHImageRequestOptions, completion: @escaping (UIImage?) -> Void) {
        if asset.representsBurst {
            PH.imageManager.requestImageData(for: asset, options: options) { data, _, _, _ in
                let image = data.flatMap { UIImage(data: $0) }
                completion(image)
            }
        } else {
            PH.imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { image, _ in
                completion(image)
            }
        }
    }
}
