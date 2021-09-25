//
//  SharedElementTransitionable.swift
//  shared-element-transition-demo
//
//  Created by Victor Samuel Cuaca on 25/09/21.
//

import UIKit

protocol SharedElementTransitionable: UIViewController {
    var sharedElementView: UIView { get }
    var dimmingBackgroundAlpha: CGFloat { get }
}

extension SharedElementTransitionable {
    var dimmingBackgroundAlpha: CGFloat { 0 }
}
