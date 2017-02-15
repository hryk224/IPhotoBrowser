# IPhotoBrowser

A simple iOS Instagram photo browser written in Swift.

<!--[![CocoaPods Compatible](http://img.shields.io/cocoapods/v/IPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/IPhotoBrowser)
[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/)-->

<img src="https://github.com/hryk224/IPhotoBrowser/wiki/images/sample1.gif" width="320" >

<img src="https://github.com/hryk224/IPhotoBrowser/wiki/images/sample2.gif" width="320" >

<img src="https://github.com/hryk224/IPhotoBrowser/wiki/images/sample3.gif" width="320" >

## Requirements
- iOS 8.0+
- Swift 3.0+
- ARC

## install

#### CocoaPods

Adding the following to your `Podfile` and running `pod install`:

```Ruby
use_frameworks!
pod 'IPhotoBrowser'
```

### import

```Swift
import IPhotoBrowser
```

## Usage

#### initialize

```Swift
convenience init(images: [UIImage], start index:Int)
convenience init(imageUrls: [URL], start index:Int)
convenience init(assets: [PHAsset], start index:Int)
```

#### IPhotoBrowserDelegate

```Swift
func iPhotoBrowser(_ iPhotoBrowser: IPhotoBrowser, didChange index: Int)
@objc optional func iPhotoBrowserDidDismissing(_ iPhotoBrowser: IPhotoBrowser)
@objc optional func iPhotoBrowserDidCanceledDismiss(_ iPhotoBrowser: IPhotoBrowser)
@objc optional func iPhotoBrowserDidPop(_ iPhotoBrowser: IPhotoBrowser)
@objc optional func iPhotoBrowserDidCanceledPop(_ iPhotoBrowser: IPhotoBrowser)
@objc optional func iPhotoBrowserMakePreviousViewScreenshot(_ iPhotoBrowser: IPhotoBrowser) -> UIImage?
```

##### Example

```Swift
let photoBrowser = IPhotoBrowser(images: images.objects, start: indexPath.item)
photoBrowser.delegate = self
navigationController?.pushViewController(photoBrowser, animated: true)
or
present(photoBrowser, animated: true, completion: nil)
```

#### IPhotoBrowserAnimatedTransitionProtocol

```Swift
var iPhotoBrowserSelectedImageViewCopy: UIImageView? { get }
var iPhotoBrowserDestinationImageViewSize: CGSize? { get }
var iPhotoBrowserDestinationImageViewCenter: CGPoint? { get }
func iPhotoBrowserTransitionWillBegin()
func iPhotoBrowserTransitionDidEnded()
```

## Photos from

* by [pakutaso.com](https://www.pakutaso.com/)

## License

This project is made available under the MIT license. See LICENSE file for details.
