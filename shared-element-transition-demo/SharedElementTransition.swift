//
//  SharedElementTransition.swift
//  shared-element-transition-demo
//
//  Created by Victor Samuel Cuaca on 25/09/21.
//

import UIKit

class SharedElementTransition: NSObject {
    enum TransitionMode {
        case present
        case dismiss
    }
    
    // MARK: - UI Components
    
    private lazy var dimmingBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var maskingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: - Variables
    
    private let transitionMode: TransitionMode
    private let duration: TimeInterval = 0.4
    private let springDamping: CGFloat = 1
    private let initialSpringVelocity: CGFloat = 0.1
    
    // MARK: - Inits
    
    init(transitionMode: TransitionMode) {
        self.transitionMode = transitionMode
    }
}

// MARK: - UIViewController Animated Transitioning

extension SharedElementTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        /// Get the `from` and `to` view controllers.
        guard let fromVC = transitionContext.viewController(forKey: .from) as? SharedElementTransitionable,
              let toVC = transitionContext.viewController(forKey: .to) as? SharedElementTransitionable
        else { return }
        
        // Create a copy of the source view and apply a mask to it.
        let sourceView = fromVC.sharedElementView
        let sourceImageView = UIImageView(image: (sourceView as? UIImageView)?.image)
        sourceImageView.contentMode = .scaleAspectFit
        sourceImageView.mask = maskingView
        
        let targetView = toVC.sharedElementView
        let targetImageView = targetView as! UIImageView
        
        /// Add the views to the `transitionContext`'s `containerView`
        let containerView = transitionContext.containerView
        containerView.addSubview(dimmingBackgroundView)
        containerView.addSubview(sourceImageView)
        
        if transitionMode == .present {
            // Calculate the initial frame.
            let absoluteSourceViewFrame = sourceView.superview!.convert(sourceView.frame, to: nil)
            let initialFrame = sourceImageView.convertFrame(from: absoluteSourceViewFrame, to: .scaleAspectFill)
                        
            // Calculate the final frame.
            toVC.view.layoutIfNeeded()
            let finalFrame = targetImageView.frame
            
            // Set the initial state.
            sourceImageView.frame = initialFrame
            maskingView.frame = sourceImageView.convert(absoluteSourceViewFrame, from: nil)
            maskingView.layer.cornerRadius = sourceView.layer.cornerRadius
            dimmingBackgroundView.frame = fromVC.view.frame
            dimmingBackgroundView.alpha = 0
            sourceView.isHidden = true
                                                              
            // Animate to the final state.
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: springDamping,
                initialSpringVelocity: initialSpringVelocity,
                options: []
            ){
                sourceImageView.frame = finalFrame
                self.maskingView.frame = targetImageView.aspectFitFrame
                self.maskingView.layer.cornerRadius = 0
                self.dimmingBackgroundView.alpha = 1
            }
            completion: { _ in
                containerView.subviews.forEach { $0.removeFromSuperview() }
                containerView.addSubview(toVC.view)
                transitionContext.completeTransition(true)
            }
        } else {
            // Calculate the final frame.
            let absoluteTargetViewFrame = targetView.superview!.convert(targetView.frame, to: nil)
            let targetImageView = targetView as! UIImageView
            let finalFrame = targetImageView.convertFrame(from: absoluteTargetViewFrame, to: .scaleAspectFill)
                        
            // Set the initial state.
            sourceImageView.frame = sourceView.frame
            maskingView.frame = sourceImageView.aspectFitFrame
            maskingView.layer.cornerRadius = sourceView.layer.cornerRadius
            dimmingBackgroundView.frame = fromVC.view.frame
            dimmingBackgroundView.alpha = fromVC.dimmingBackgroundAlpha
            sourceView.isHidden = true
            fromVC.view.isHidden = true
          
            // Animate to the final state.
            
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: springDamping,
                initialSpringVelocity: initialSpringVelocity,
                options: []
            ){
                sourceImageView.frame = finalFrame
                self.maskingView.frame = sourceImageView.convert(absoluteTargetViewFrame, from: nil)
                self.maskingView.layer.cornerRadius = targetView.layer.cornerRadius
                self.dimmingBackgroundView.alpha = 0
            }
            completion: { _ in
                targetView.isHidden = false
                transitionContext.completeTransition(true)
            }
        }
    }
}
