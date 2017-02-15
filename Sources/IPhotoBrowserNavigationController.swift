//
//  IPhotoBrowserNavigationController.swift
//  IPhotoBrowser
//
//  Created by hiroyuki yoshida on 2017/02/21.
//
//

import UIKit

open class IPhotoBrowserNavigationController: UINavigationController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.isEnabled = false
    }
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate = self
    }
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate = nil
    }
}

extension IPhotoBrowserNavigationController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let sourceProtocol = fromVC as? IPhotoBrowserAnimatedTransitionProtocol, let destinationProtocol = toVC as? IPhotoBrowserAnimatedTransitionProtocol else { return nil }
        let animator = IPhotoBrowserAnimatedTransition(operation: operation)
        animator.sourceProtocol = sourceProtocol
        animator.destinationProtocol = destinationProtocol
        (toVC as? IPhotoBrowser)?.segueType = .pushed
        return animator
    }
}
