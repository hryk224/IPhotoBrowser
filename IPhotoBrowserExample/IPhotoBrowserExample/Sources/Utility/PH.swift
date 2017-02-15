//
//  Photos.swift
//  IPhotoBrowserExample
//
//  Created by yoshida hiroyuki on 2017/02/15.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import Photos

final class PH {
    static let shared = PH()
    static var imageManager: PHImageManager {
        return PHImageManager.default()
    }
    fileprivate var albumCollection: PHAlbumCollection = PHAlbumCollection(assetCollections: PHUtility.photoAlbums)
    func reloadAlbumCollection() {
        albumCollection = PHAlbumCollection(assetCollections: PHUtility.photoAlbums)
    }
    func photos(albumIndex: Int) -> [PHPhoto] {
        guard albumCollection.albums.count > albumIndex else { return [] }
        return albumCollection.albums[albumIndex].photos
    }
    func numberOfPhotos(albumIndex: Int) -> Int {
        return photos(albumIndex: albumIndex).count
    }
}

// MARK: - Image Fetching
extension PH {
    func fetchThumbnail(albumIndex: Int, photoIndex: Int, size: CGSize, completion: @escaping (UIImage?) -> Void) {
        let photo: PHPhoto = albumCollection.albums[albumIndex].photos[photoIndex]
        photo.fetchImage(type: .thumbnail, completion: completion)
    }
    func fetchDisplayedSizeImage(albumIndex: Int, photoIndex: Int, completion: @escaping (UIImage?) -> Void) {
        let photo: PHPhoto = albumCollection.albums[albumIndex].photos[photoIndex]
        photo.fetchImage(type: .displayed, completion: completion)
    }
}
