//
//  MainViewController.swift
//  IPhotoBrowserExample
//
//  Created by hryk224 on 2017/02/15.
//  Copyright © 2017年 hryk224. All rights reserved.
//

import UIKit.UIViewController

final class MainViewController: UIViewController {
    var patterns = ["in-app image", "camera roll"]
    let identifier = "MainCell"
    var cellHeight: CGFloat {
        return (UIScreen.main.bounds.height - 64) / CGFloat(patterns.count)
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
        return patterns.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
        cell.textLabel?.text = patterns[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = .boldSystemFont(ofSize: 24)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let viewController = InAppImageViewController.makeFromStoryboard()
            navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
