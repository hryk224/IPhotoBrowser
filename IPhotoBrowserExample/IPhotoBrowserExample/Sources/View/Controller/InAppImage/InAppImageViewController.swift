//
//  InAppImageViewController.swift
//  IPhotoBrowserExample
//
//  Created by hryk224 on 2017/02/15.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import UIKit.UICollectionViewController
import IPhotoBrowser

final class InAppImageViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(AssetCollectionViewCell.nib, forCellWithReuseIdentifier: AssetCollectionViewCell.identifier)
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
        return 2
    }
    private var cellSize: CGSize {
        let spaceCount = (lineCount - 1).cgFloat
        let width = (UIScreen.main.bounds.width - (spaceCount * layout.minimumLineSpacing)) / lineCount.cgFloat
        return CGSize(width: width, height: width)
    }
    fileprivate var images: Assets.Image {
        return Assets.Image.share
    }
    static func makeFromStoryboard() -> InAppImageViewController {
        let storyboard = UIStoryboard(name: "InAppImageViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as! InAppImageViewController
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = MainViewController.Row.inAppImage.title
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension InAppImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetCollectionViewCell.identifier, for: indexPath) as! AssetCollectionViewCell
        cell.configure(image: images.objects[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photos = images.objects.enumerated()
            .flatMap { ($0 + 1, $1) }
            .flatMap { IPhoto(image: $1, title: "\($0)/\(images.count)") }
        let photoBrowser = IPhotoBrowser(photos: photos, start: indexPath.item)
        photoBrowser.delegate = self
        navigationController?.pushViewController(photoBrowser, animated: true)
    }
}

// MARK: - IPhotoBrowserAnimatedTransitionProtocol
extension InAppImageViewController: IPhotoBrowserAnimatedTransitionProtocol {
    var iPhotoBrowserSelectedImageViewCopy: UIImageView? {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first, let cell = collectionView.cellForItem(at: indexPath) as? AssetCollectionViewCell else {
            return nil
        }
        let sourceImageView = UIImageView(image: cell.imageView.image)
        sourceImageView.contentMode = cell.imageView.contentMode
        sourceImageView.clipsToBounds = true
        sourceImageView.frame = cell.contentView.convert(cell.imageView.frame, to: view)
        return sourceImageView
    }
    var iPhotoBrowserDestinationImageViewSize: CGSize? {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else {
            return nil
        }
        let cell = collectionView.cellForItem(at: indexPath) as? AssetCollectionViewCell
        return cell?.imageView.frame.size
    }
    var iPhotoBrowserDestinationImageViewCenter: CGPoint? {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first, let cell = collectionView.cellForItem(at: indexPath) as? AssetCollectionViewCell else {
            return nil
        }
        return cell.contentView.convert(cell.imageView.center, to: view)
    }
    func iPhotoBrowserTransitionWillBegin() {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else {
            return
        }
        let cell = collectionView.cellForItem(at: indexPath) as? AssetCollectionViewCell
        cell?.imageView.isHidden = true
    }
    func iPhotoBrowserTransitionDidEnded() {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else {
            return
        }
        let cell = collectionView.cellForItem(at: indexPath) as? AssetCollectionViewCell
        cell?.imageView.isHidden = false
    }
}

// MARK: - IPhotoBrowserDelegate
extension InAppImageViewController: IPhotoBrowserDelegate {
    func iPhotoBrowser(_ iPhotoBrowser: IPhotoBrowser, didChange index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
    }
    func iPhotoBrowserMakeViewScreenshotIfNeeded(_ iPhotoBrowser: IPhotoBrowser) -> UIImage? {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else {
            return nil
        }
        let cell = collectionView.cellForItem(at: indexPath) as? AssetCollectionViewCell
        cell?.imageView.isHidden = true
        let image = view.screenshot
        cell?.imageView.isHidden = false
        return image
    }
}
