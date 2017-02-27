# IPhotoBrowser

A simple iOS photo browser written in Swift.

[![CocoaPods Compatible](http://img.shields.io/cocoapods/v/IPhotoBrowser.svg?style=flat)](http://cocoadocs.org/docsets/IPhotoBrowser)
[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/)

<img src="https://github.com/hryk224/IPhotoBrowser/wiki/images/sample1.gif" width="320" > <img src="https://github.com/hryk224/IPhotoBrowser/wiki/images/sample2.gif" width="320" >

<img src="https://github.com/hryk224/IPhotoBrowser/wiki/images/sample3.gif" width="320" > <img src="https://github.com/hryk224/IPhotoBrowser/wiki/images/sample4.gif" width="320" >

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
init(images: [UIImage], start index:Int)
init(imageUrls: [URL], start index:Int)
init(assets: [PHAsset], start index:Int)
init(photos: [IPhoto], start index:Int)
```

#### IPhotoBrowserDelegate

```Swift
func iPhotoBrowser(_ iPhotoBrowser: IPhotoBrowser, didChange index: Int)

// Dismiss
@objc optional func iPhotoBrowserDidDismissing(_ iPhotoBrowser: IPhotoBrowser)
@objc optional func iPhotoBrowserDidCanceledDismiss(_ iPhotoBrowser: IPhotoBrowser)

// Pop
@objc optional func iPhotoBrowserDidPop(_ iPhotoBrowser: IPhotoBrowser)
@objc optional func iPhotoBrowserDidCanceledPop(_ iPhotoBrowser: IPhotoBrowser)
/// This screenshot is used for pop transitions.
/// Used background image to IPhotoBrowser.
@objc optional func iPhotoBrowserMakeViewScreenshotIfNeeded(_ iPhotoBrowser: IPhotoBrowser) -> UIImage?
```

##### Example

```Swift
let photoBrowser = IPhotoBrowser(images: images, start: 0)
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

#### Entity

`IPhoto`

```Swift
struct IPhoto {
  let image: UIImage?
  let imageUrl: URL?
  let asset: PHAsset?
  let title: String?
  let description: String?
}
```

## Photos from

* by [pakutaso.com](https://www.pakutaso.com/)

## License

This project is made available under the MIT license. See LICENSE file for details.
