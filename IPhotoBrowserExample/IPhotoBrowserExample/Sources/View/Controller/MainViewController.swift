//
//  MainViewController.swift
//  IPhotoBrowserExample
//
//  Created by hryk224 on 2017/02/15.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import IPhotoBrowser
import UIKit.UIViewController

final class MainViewController: UIViewController {
    enum Row: Int, CustomStringConvertible {
        case inAppImage = 0, cameraRoll, horizontal, imageUrl
        static var count = 4
        var title: String {
            switch self {
            case .inAppImage, .horizontal: return "In-app"
            case .cameraRoll: return "Camera"
            case .imageUrl: return "Imageurl"
            }
        }
        var description: String {
            switch self {
            case .inAppImage: return "In-app images"
            case .cameraRoll: return "Camera roll"
            case .horizontal: return "In-app images\n(Horizontal)"
            case .imageUrl: return "Image url\n(tableView)"
            }
        }
    }
    let identifier = "MainCell"
    var cellHeight: CGFloat {
        return max(100, (UIScreen.main.bounds.height - 64) / CGFloat(Row.count))
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
            tableView.rowHeight = cellHeight
            tableView.estimatedRowHeight = cellHeight
            tableView.separatorInset = .zero
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = Row(rawValue: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
        cell.textLabel?.text = row?.description
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = .boldSystemFont(ofSize: 18)
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let row = Row(rawValue: indexPath.row) else { return }
        switch row {
        case .inAppImage:
            let viewController = InAppImageViewController.makeFromStoryboard()
            navigationController?.pushViewController(viewController, animated: true)
        case .cameraRoll:
            let viewController = CameraRollViewController.makeFromStoryboard()
            navigationController?.pushViewController(viewController, animated: true)
        case .horizontal:
            IPhotoWebImageCache.default.clearMemoryCache()
            let viewController = HorizontalViewController.makeFromStoryboard()
            navigationController?.pushViewController(viewController, animated: true)
        case .imageUrl:
            IPhotoWebImageCache.default.clearMemoryCache()
            let viewController = ImageUrlViewController.makeFromStoryboard()
            navigationController?.pushViewController(viewController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
