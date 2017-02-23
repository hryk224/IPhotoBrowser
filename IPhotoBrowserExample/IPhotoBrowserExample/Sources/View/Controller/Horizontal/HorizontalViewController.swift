//
//  HorizontalViewController.swift
//  IPhotoBrowserExample
//
//  Created by hiroyuki yoshida on 2017/02/17.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import UIKit
import IPhotoBrowser

class HorizontalViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(AssetCollectionViewCell.nib, forCellWithReuseIdentifier: AssetCollectionViewCell.identifier)
        }
    }
    fileprivate var photos: Assets.Photo {
        return Assets.Photo.share
    }
    static func makeFromStoryboard() -> HorizontalViewController {
        let storyboard = UIStoryboard(name: "HorizontalViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as! HorizontalViewController
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = MainViewController.Row.horizontal.title
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HorizontalViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetCollectionViewCell.identifier, for: indexPath) as! AssetCollectionViewCell
        cell.configure(image: photos.objects[indexPath.item].image)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoBrowser = IPhotoBrowser(photos: photos.objects, start: indexPath.item)
        photoBrowser.delegate = self
        present(photoBrowser, animated: true, completion: nil)
    }
}

// MARK: - IPhotoBrowserAnimatedTransitionProtocol
extension HorizontalViewController: IPhotoBrowserAnimatedTransitionProtocol {
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
extension HorizontalViewController: IPhotoBrowserDelegate {
    func iPhotoBrowser(_ iPhotoBrowser: IPhotoBrowser, didChange index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
    }
    func iPhotoBrowserDidDismissing(_ iPhotoBrowser: IPhotoBrowser) {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else {
            return
        }
        let cell = collectionView.cellForItem(at: indexPath) as? AssetCollectionViewCell
        cell?.imageView.isHidden = true
    }
    func iPhotoBrowserDidCanceledDismiss(_ iPhotoBrowser: IPhotoBrowser) {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else {
            return
        }
        let cell = collectionView.cellForItem(at: indexPath) as? AssetCollectionViewCell
        cell?.imageView.isHidden = false
    }
}
