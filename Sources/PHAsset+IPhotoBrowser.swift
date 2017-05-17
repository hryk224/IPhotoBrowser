//
//  PHAsset+IPhotoBrowswer.swift
//  IPhotoBrowser
//
//  Created by yoshida hiroyuki on 2017/02/20.
//
//

import Photos

extension PHAsset {
    private var imageManager: PHImageManager {
        return PHCachingImageManager.default()
    }
    func fetchImage(targetSize: CGSize, options: PHImageRequestOptions, completion: @escaping (UIImage?) -> Void) {
        if representsBurst {
            imageManager.requestImageData(for: self, options: options) { data, _, _, _ in
                let image = data.flatMap { UIImage(data: $0) }
                completion(image)
            }
        } else {
            imageManager.requestImage(for: self, targetSize: targetSize, contentMode: .aspectFit, options: options) { image, _ in
                completion(image)
            }
        }
    }
}
