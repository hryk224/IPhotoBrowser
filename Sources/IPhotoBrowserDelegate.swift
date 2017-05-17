//
//  IPhotoBrowserDelegate.swift
//  IPhotoBrowser
//
//  Created by hiroyuki yoshida on 2017/02/20.
//
//

import UIKit

@objc public protocol IPhotoBrowserDelegate: class {
    func iPhotoBrowser(_ iPhotoBrowser: IPhotoBrowser, didChange index: Int)
    @objc optional func iPhotoBrowserDidDismissing(_ iPhotoBrowser: IPhotoBrowser)
    @objc optional func iPhotoBrowserDidCanceledDismiss(_ iPhotoBrowser: IPhotoBrowser)
    @objc optional func iPhotoBrowserDidPop(_ iPhotoBrowser: IPhotoBrowser)
    @objc optional func iPhotoBrowserDidCanceledPop(_ iPhotoBrowser: IPhotoBrowser)
    @objc optional func iPhotoBrowserMakeViewScreenshotIfNeeded(_ iPhotoBrowser: IPhotoBrowser) -> UIImage?
    @objc optional func iPhotoBrowserTouchRightButton(_ iPhotoBrowser: IPhotoBrowser, selectedItemAt index: Int)
}
