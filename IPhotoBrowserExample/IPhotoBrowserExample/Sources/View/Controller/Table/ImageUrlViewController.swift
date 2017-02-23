//
//  ColorViewController.swift
//  IPhotoBrowserExample
//
//  Created by hryk224 on 2017/02/15.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import UIKit
import IPhotoBrowser

final class ImageUrlViewController: UITableViewController {
    static func makeFromStoryboard() -> ImageUrlViewController {
        let storyboard = UIStoryboard(name: "ImageUrlViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as! ImageUrlViewController
    }
    fileprivate var imageUrls: Assets.ImageURL {
        return Assets.ImageURL.share
    }
    fileprivate var indexPathForSelectedRow: IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(WebImageTableViewCell.nib, forCellReuseIdentifier: WebImageTableViewCell.identifier)
        tableView.separatorInset = .zero
        title = MainViewController.Row.imageUrl.title
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ImageUrlViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageUrls.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WebImageTableViewCell.identifier, for: indexPath) as! WebImageTableViewCell
        cell.configure(imageUrl: imageUrls.objects[indexPath.row])
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photoBrowser = IPhotoBrowser(imageUrls: imageUrls.objects, start: indexPath.item)
        photoBrowser.delegate = self
        DispatchQueue.main.async {
            self.present(photoBrowser, animated: true, completion: nil)
        }
        indexPathForSelectedRow = indexPath
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - IPhotoBrowserAnimatedTransitionProtocol
extension ImageUrlViewController: IPhotoBrowserAnimatedTransitionProtocol {
    var iPhotoBrowserSelectedImageViewCopy: UIImageView? {
        guard let indexPath = indexPathForSelectedRow, let cell = tableView.cellForRow(at: indexPath) as? WebImageTableViewCell else {
            return nil
        }
        let sourceImageView = UIImageView(image: cell.webImageView.image)
        sourceImageView.contentMode = cell.webImageView.contentMode
        sourceImageView.clipsToBounds = true
        sourceImageView.frame = cell.contentView.convert(cell.webImageView.frame, to: navigationController?.view)
        sourceImageView.layer.cornerRadius = cell.webImageView.layer.cornerRadius
        return sourceImageView
    }
    var iPhotoBrowserDestinationImageViewSize: CGSize? {
        guard let indexPath = indexPathForSelectedRow else {
            return nil
        }
        let cell = tableView.cellForRow(at: indexPath) as? WebImageTableViewCell
        return cell?.webImageView.frame.size
    }
    var iPhotoBrowserDestinationImageViewCenter: CGPoint? {
        guard let indexPath = indexPathForSelectedRow, let cell = tableView.cellForRow(at: indexPath) as? WebImageTableViewCell else {
            return nil
        }
        return cell.contentView.convert(cell.webImageView.center, to: navigationController?.view)
    }
    func iPhotoBrowserTransitionWillBegin() {
        guard let indexPath = indexPathForSelectedRow else {
            return
        }
        let cell = tableView.cellForRow(at: indexPath) as? WebImageTableViewCell
        cell?.webImageView.isHidden = true
    }
    func iPhotoBrowserTransitionDidEnded() {
        guard let indexPath = indexPathForSelectedRow else {
            return
        }
        let cell = tableView.cellForRow(at: indexPath) as? WebImageTableViewCell
        cell?.webImageView.isHidden = false
    }
}

// MARK: - IPhotoBrowserDelegate
extension ImageUrlViewController: IPhotoBrowserDelegate {
    func iPhotoBrowser(_ iPhotoBrowser: IPhotoBrowser, didChange index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
        indexPathForSelectedRow = indexPath
    }
    func iPhotoBrowserDidDismissing(_ iPhotoBrowser: IPhotoBrowser) {
        guard let indexPath = indexPathForSelectedRow else {
            return
        }
        let cell = tableView.cellForRow(at: indexPath) as? WebImageTableViewCell
        cell?.webImageView.isHidden = true
    }
    func iPhotoBrowserDidCanceledDismiss(_ iPhotoBrowser: IPhotoBrowser) {
        guard let indexPath = indexPathForSelectedRow else {
            return
        }
        let cell = tableView.cellForRow(at: indexPath) as? WebImageTableViewCell
        cell?.webImageView.isHidden = false
    }
}
