//
//  CameraRollViewController.swift
//  IPhotoBrowserExample
//
//  Created by hryk224 on 2017/02/15.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import UIKit.UICollectionViewController
import IPhotoBrowser

final class CameraRollViewController: UIViewController {
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
        return 4
    }
    private var cellSize: CGSize {
        let spaceCount = (lineCount - 1).cgFloat
        let width = (UIScreen.main.bounds.width - (spaceCount * layout.minimumLineSpacing)) / lineCount.cgFloat
        return CGSize(width: width, height: width)
    }
    fileprivate var photos: [PHPhoto] {
        return PH.shared.photos(albumIndex: 0)
    }
    static func makeFromStoryboard() -> CameraRollViewController {
        let storyboard = UIStoryboard(name: "CameraRollViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as! CameraRollViewController
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        photosRequestAuthorization()
    }
}

// MARK: - Private
private extension CameraRollViewController {
    func reloadData(afterDetermined: Bool = false) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    func photosRequestAuthorization() {
        PHUtility.available { [weak self] (isAvailable, afterDetermined) in
            if isAvailable{
                self?.fetchAssets()
            } else {
                self?.showSettingAlert()
            }
        }
    }
    private func fetchAssets() {
        PH.shared.reloadAlbumCollection()
        reloadData()
    }
    func showSettingAlert() {
        let alertController = UIAlertController(title: "Access has been denied.\nPlease change from settings.", message: nil, preferredStyle: .alert)
        present(alertController, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension CameraRollViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetCollectionViewCell.identifier, for: indexPath) as! AssetCollectionViewCell
        cell.configure(photo: photos[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoBrowser = IPhotoBrowser(assets: photos.map { $0.asset }, start: indexPath.item)
        photoBrowser.configure(backgroundColor: .white)
        photoBrowser.delegate = self
        present(photoBrowser, animated: true, completion: nil)
    }
}

// MARK: - IPhotoBrowserAnimatedTransitionProtocol
extension CameraRollViewController: IPhotoBrowserAnimatedTransitionProtocol {
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
extension CameraRollViewController: IPhotoBrowserDelegate {
    func iPhotoBrowser(_ iPhotoBrowser: IPhotoBrowser, didChange index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
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
