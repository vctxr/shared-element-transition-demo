//
//  SharedElementInteractiveTransition.swift
//  shared-element-transition-demo
//
//  Created by Victor Samuel Cuaca on 02/10/21.
//

import UIKit

class SharedElementInteractiveTransition: UIPercentDrivenInteractiveTransition {
    private(set) var interactionInProgress = false

    private var shouldCompleteTransition = false
    private let presentViewController: () -> Void

    init(attachTo view: UIView, presentViewController: @escaping () -> Void) {
        self.presentViewController = presentViewController
        super.init()
        prepareGestureRecognizer(in: view)
    }
    
    private func prepareGestureRecognizer(in view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    @objc func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            interactionInProgress = true
            presentViewController()
            
        case .changed:
            let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
            let progress = max(abs(translation.x), abs(translation.y)) / 400
            shouldCompleteTransition = progress > 0.25
            update(progress)

        case .cancelled:
            interactionInProgress = false
            cancel()
            
        case .ended:
            interactionInProgress = false
            if shouldCompleteTransition {
                finish()
            } else {
                cancel()
            }
            
        default:
            break
        }
    }
}
