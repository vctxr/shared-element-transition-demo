//
//  SharedElementAnimator.swift
//  shared-element-transition-demo
//
//  Created by Victor Samuel Cuaca on 12/10/21.
//

import UIKit

struct SharedElementAnimator {
    struct Constants {
        static let transitionDuration: TimeInterval = 0.35
        static let springDamping: CGFloat = 0.85
        static let initialSpringVelocity: CGFloat = 0.1
        static let animationOptions: UIView.AnimationOptions = []
    }
    
    static func animate(_ animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: Constants.transitionDuration,
            delay: 0,
            usingSpringWithDamping: Constants.springDamping,
            initialSpringVelocity: Constants.initialSpringVelocity,
            options: Constants.animationOptions,
            animations: animations,
            completion: completion
        )
    }
}
