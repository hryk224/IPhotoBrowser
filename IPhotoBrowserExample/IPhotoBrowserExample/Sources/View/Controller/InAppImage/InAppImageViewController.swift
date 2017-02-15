//
//  InAppImageViewController.swift
//  IPhotoBrowserExample
//
//  Created by yoshida hiroyuki on 2017/02/15.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import UIKit.UICollectionViewController

final class InAppImageViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        }
    }
    @IBOutlet weak var layout: UICollectionViewFlowLayout! {
        didSet {
            layout.minimumLineSpacing = 0.5
            layout.minimumInteritemSpacing = 0.5
            layout.itemSize = cellSize
        }
    }
    private var lineCount: Int {
        return 4
    }
    private var cellSize: CGSize {
        let spaceCount = (lineCount - 1).cgFloat
        let width = (UIScreen.main.bounds.width - (spaceCount * layout.minimumLineSpacing)) / lineCount.cgFloat
        return CGSize(width: width, height: width)
    }
    fileprivate var colors: Assets.Color {
        return Assets.Color.share
    }
    fileprivate var images: Assets.Image {
        return Assets.Image.share
    }
    static func makeFromStoryboard() -> InAppImageViewController {
        let storyboard = UIStoryboard(name: "InAppImageViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as! InAppImageViewController
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension InAppImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = colors.objects[indexPath.item]
        return cell
    }
}
