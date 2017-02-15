//
//  PHUtility.swift
//  IPhotoBrowserExample
//
//  Created by hryk224 on 2017/02/15.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import Photos

struct PHUtility {
    static var photoAlbums: [PHAssetCollection] {
        return collectAlbumWithMediaType(.image)
    }
    private static func collectAlbumWithMediaType(_ mediaType: PHAssetMediaType) -> [PHAssetCollection] {
        var assetCollections: [PHAssetCollection] = []
        let enumerateBlock: ((PHAssetCollection, Int, UnsafeMutablePointer<ObjCBool>) -> Void) = { collection, _, _ in
            let assets = collectAssetsWithMediaType(collection, mediaType: mediaType)
            guard assets.count > 0 else { return }
            let assetCollection = PHAssetCollection.transientAssetCollection(with: assets, title: collection.localizedTitle)
            assetCollections.append(assetCollection)
        }
        PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).enumerateObjects(enumerateBlock)
        PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil).enumerateObjects(enumerateBlock)
        return assetCollections
    }
    private static func collectAssetsWithMediaType(_ collection: PHAssetCollection, mediaType: PHAssetMediaType) -> [PHAsset] {
        var assets: [PHAsset] = []
        PHAsset.fetchAssets(in: collection, options: nil).enumerateObjects({ asset, _, _ in
            guard asset.mediaType == mediaType else { return }
            assets.append(asset)
        })
        return assets.reversed()
    }
    static func available(completion: @escaping ((_ isAvailable: Bool, _ afterDetermined: Bool) -> Void)) {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch authorizationStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                completion(status == .authorized, true)
            }
        default:
            completion(authorizationStatus == .authorized, false)
        }
    }
}
