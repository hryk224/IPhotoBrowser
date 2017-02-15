//
//  IPhotoBrowserAnimatedTransition.swift
//  IPhotoBrowser
//
//  Created by yoshida hiroyuki on 2017/02/17.
//
//

import UIKit

public protocol IPhotoBrowserAnimatedTransitionProtocol: class {
    var iPhotoBrowserSelectedImageViewCopy: UIImageView? { get }
    var iPhotoBrowserDestinationImageViewSize: CGSize? { get }
    var iPhotoBrowserDestinationImageViewCenter: CGPoint? { get }
    func iPhotoBrowserTransitionWillBegin()
    func iPhotoBrowserTransitionDidEnded()
}

final class IPhotoBrowserAnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let transitionDuration: TimeInterval
    var sourceProtocol: IPhotoBrowserAnimatedTransitionProtocol?
    var destinationProtocol: IPhotoBrowserAnimatedTransitionProtocol?
    fileprivate var isGo: Bool {
        return operation == .push || isPresent == true
    }
    fileprivate var segueType: SegueType {
        return (operation != nil) ? .pushed : .presented
    }
    private var isPresent: Bool?
    private var operation: UINavigationControllerOperation?
    required init(isPresent: Bool, transitionDuration: TimeInterval = 0.35) {
        self.isPresent = isPresent
        self.transitionDuration = transitionDuration
        super.init()
    }
    required init(operation: UINavigationControllerOperation, transitionDuration: TimeInterval = 0.35) {
        self.operation = operation
        self.transitionDuration = transitionDuration
        super.init()
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isGo == true {
            goAnimation(using: transitionContext)
        } else {
            backAnimation(using: transitionContext)
        }
    }
    func cancel(using transitionContext: UIViewControllerContextTransitioning) {
        let cancelled = transitionContext.transitionWasCancelled
        transitionContext.completeTransition(!cancelled)
    }
}

// MARK: - Private
private extension IPhotoBrowserAnimatedTransition {
    func goAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? IPhotoBrowser,
            let sourceImageView = sourceProtocol?.iPhotoBrowserSelectedImageViewCopy,
            let targetSize = destinationProtocol?.iPhotoBrowserDestinationImageViewSize,
            let targetCenter = destinationProtocol?.iPhotoBrowserDestinationImageViewCenter else {
                simpleGoAnimation(using: transitionContext)
                return
        }
        let containerView = transitionContext.containerView
        var newTargetSize: CGSize = targetSize
        // Resizing
        if let image = sourceImageView.image {
            switch sourceImageView.contentMode {
            case .scaleAspectFit:
                // No need to resize
                break
            case .scaleAspectFill where image.size.width > image.size.height:
                let ratio = image.size.height / image.size.width
                newTargetSize.height = newTargetSize.width * ratio
                if newTargetSize.height > targetSize.height {
                    let ratio = targetSize.height / newTargetSize.height
                    newTargetSize.height = targetSize.height
                    newTargetSize.width *= ratio
                }
            case .scaleAspectFill where image.size.height >= image.size.width:
                let ratio = image.size.width / image.size.height
                newTargetSize.width = newTargetSize.height * ratio
                if newTargetSize.width > targetSize.width {
                    let ratio = targetSize.width / newTargetSize.width
                    newTargetSize.width = targetSize.width
                    newTargetSize.height *= ratio
                }
            default:
                fatalError("Does not support this content mode. Please use scaleAspectFit or scaleAspectFill")
            }
        }
        if sourceImageView.layer.cornerRadius > 0 {
            let cornerRadius = sourceImageView.layer.cornerRadius
            sourceImageView.layer.cornerRadius = 0
            sourceImageView.cornerRadiusAnimation(cornerRadius, to: 0, duration: transitionDuration(using: transitionContext))
        }
        toVC.view.insertSubview(sourceImageView, aboveSubview: toVC.containerView)
        containerView.addSubview(toVC.view)
        sourceProtocol?.iPhotoBrowserTransitionWillBegin()
        destinationProtocol?.iPhotoBrowserTransitionWillBegin()
        toVC.overlayView?.alpha = 0
        let animations: (() -> Void) = {
            sourceImageView.frame.size = newTargetSize
            sourceImageView.center = targetCenter
            toVC.overlayView?.alpha = 1
        }
        let completion: ((Bool) -> Void) = { finished in
            guard finished else { return }
            sourceImageView.removeFromSuperview()
            self.sourceProtocol?.iPhotoBrowserTransitionDidEnded()
            self.destinationProtocol?.iPhotoBrowserTransitionDidEnded()
            let cancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!cancelled)
        }
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: animations,
                       completion: completion)
    }
    func simpleGoAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else {
            cancel(using: transitionContext)
            return
        }
        let containerView = transitionContext.containerView
        toView.alpha = 0
        containerView.addSubview(toView)
        sourceProtocol?.iPhotoBrowserTransitionWillBegin()
        destinationProtocol?.iPhotoBrowserTransitionWillBegin()
        let animations: (() -> Void) = {
            toView.alpha = 1
        }
        let completion: ((Bool) -> Void) = { finished in
            guard finished else { return }
            self.sourceProtocol?.iPhotoBrowserTransitionDidEnded()
            self.destinationProtocol?.iPhotoBrowserTransitionDidEnded()
            let cancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!cancelled)
        }
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: animations,
                       completion: completion)
    }
    func backAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let controller = transitionContext.viewController(forKey: .from) as? IPhotoBrowser,
            let toVC = transitionContext.viewController(forKey: .to),
            let sourceImageView = sourceProtocol?.iPhotoBrowserSelectedImageViewCopy,
            let targetSize = destinationProtocol?.iPhotoBrowserDestinationImageViewSize,
            let targetCenter = destinationProtocol?.iPhotoBrowserDestinationImageViewCenter else {
                simpleBackAnimation(using: transitionContext)
                return
        }
        let containerView = transitionContext.containerView
        var newTargetFrame: CGRect = CGRect(origin: .zero, size: targetSize)
        let imageContainerView = UIView(frame: sourceImageView.frame)
        imageContainerView.clipsToBounds = true
        sourceImageView.frame.origin = .zero
        imageContainerView.addSubview(sourceImageView)
        if let targetImageView = destinationProtocol?.iPhotoBrowserSelectedImageViewCopy {
            // Resizing
            if let image = sourceImageView.image {
                switch targetImageView.contentMode {
                case .scaleAspectFit:
                    // No need to resize
                    break
                case .scaleAspectFill:
                    if image.size.width > image.size.height {
                        let ratio = image.size.width / image.size.height
                        newTargetFrame.size.width = newTargetFrame.size.height * ratio
                        newTargetFrame.origin.x -= (newTargetFrame.size.width - newTargetFrame.size.height) / 2
                    } else {
                        let ratio = image.size.height / image.size.width
                        newTargetFrame.size.height = newTargetFrame.size.width * ratio
                        newTargetFrame.origin.y -= (newTargetFrame.size.height - newTargetFrame.size.width) / 2
                    }
                default:
                    fatalError("Does not support this content mode. Please use scaleAspectFit or scaleAspectFill")
                }
            }
        }
        if segueType.isPushed {
            containerView.addSubview(toVC.view)
        }
        containerView.addSubview(controller.view)
        controller.imageView?.removeFromSuperview()
        containerView.addSubview(imageContainerView)
        sourceProtocol?.iPhotoBrowserTransitionWillBegin()
        destinationProtocol?.iPhotoBrowserTransitionWillBegin()
        if let targetImageView = destinationProtocol?.iPhotoBrowserSelectedImageViewCopy, targetImageView.layer.cornerRadius > 0 {
            sourceImageView.cornerRadiusAnimation(0, to: targetImageView.layer.cornerRadius, duration: transitionDuration(using: transitionContext))
        }
        let animations = {
            sourceImageView.frame = newTargetFrame
            imageContainerView.frame.size = targetSize
            imageContainerView.center = targetCenter
            controller.overlayView?.alpha = 0
        }
        let completion: ((Bool) -> Void) = { finished in
            guard finished else { return }
            imageContainerView.removeFromSuperview()
            self.sourceProtocol?.iPhotoBrowserTransitionDidEnded()
            self.destinationProtocol?.iPhotoBrowserTransitionDidEnded()
            let cancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!cancelled)
        }
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: animations,
                       completion: completion)
    }
    func simpleBackAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from), let toVC = transitionContext.viewController(forKey: .to) else {
            cancel(using: transitionContext)
            return
        }
        let containerView = transitionContext.containerView
        if segueType.isPushed {
            containerView.addSubview(toVC.view)
        }
        containerView.addSubview(fromView)
        sourceProtocol?.iPhotoBrowserTransitionWillBegin()
        destinationProtocol?.iPhotoBrowserTransitionWillBegin()
        let animations: (() -> Void) = {
            fromView.alpha = 0
        }
        let completion: ((Bool) -> Void) = { finished in
            guard finished else { return }
            self.sourceProtocol?.iPhotoBrowserTransitionDidEnded()
            self.destinationProtocol?.iPhotoBrowserTransitionDidEnded()
            let cancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!cancelled)
        }
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: animations,
                       completion: completion)
    }
}
