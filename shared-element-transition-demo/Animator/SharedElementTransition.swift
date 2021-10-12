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
    
    // MARK: - Inits
    
    init(transitionMode: TransitionMode) {
        self.transitionMode = transitionMode
    }
    
    // MARK: - Private Functions
    
    private func animatePresentation(
        sourceView: UIView,
        absoluteSourceViewFrame: CGRect,
        sourceImageView: UIImageView,
        absoluteTargetViewFrame: CGRect,
        targetImageView: UIImageView,
        transitionContext: UIViewControllerContextTransitioning
    ) {
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        let containerView = transitionContext.containerView
        
        /// Calculate the `sourceImageView` frame as if it were `scaleAspectFill`.
        sourceImageView.contentMode = .scaleAspectFit
        let initialFrame = sourceImageView.convertFrame(in: absoluteSourceViewFrame, to: .scaleAspectFill)

        // Set the initial state.
        sourceImageView.frame = initialFrame
        maskingView.frame = sourceImageView.convert(absoluteSourceViewFrame, from: nil)
        maskingView.layer.cornerRadius = sourceView.layer.cornerRadius
        dimmingBackgroundView.frame = containerView.frame
        dimmingBackgroundView.alpha = 0
        sourceView.isHidden = true
                                                          
        // Animate to the final state.
        SharedElementAnimator.animate {
            sourceImageView.frame = absoluteTargetViewFrame
            self.maskingView.frame = targetImageView.aspectFitFrame
            self.maskingView.layer.cornerRadius = 0
            self.dimmingBackgroundView.alpha = 1
        } completion: { isComplete in
            /// To remove all uneccessary `subviews` after animation is completed.
            containerView.subviews.forEach { $0.removeFromSuperview() }
            
            if transitionContext.transitionWasCancelled {
                sourceView.isHidden = false
                transitionContext.cancelInteractiveTransition()
                transitionContext.completeTransition(false)
            } else {
                containerView.addSubview(toVC.view)
                transitionContext.finishInteractiveTransition()
                transitionContext.completeTransition(true)
            }
        }
    }
    
    private func animateDismissal(
        sourceView: UIView,
        absoluteSourceViewFrame: CGRect,
        sourceImageView: UIImageView,
        targetView: UIView,
        absoluteTargetViewFrame: CGRect,
        targetImageView: UIImageView,
        transitionContext: UIViewControllerContextTransitioning
    ) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? SharedElementTransitionable else { return }
        let containerView = transitionContext.containerView

        /// Calculate the `sourceImageView` frame as if it were `scaleAspectFit`.
        sourceImageView.contentMode = .scaleAspectFill
        let initialFrame = sourceImageView.convertFrame(in: absoluteSourceViewFrame, to: .scaleAspectFit)

        // Set the initial state.
        sourceImageView.frame = initialFrame
        maskingView.frame = sourceImageView.aspectFitFrame
        maskingView.layer.cornerRadius = sourceView.layer.cornerRadius
        dimmingBackgroundView.frame = containerView.frame
        dimmingBackgroundView.alpha = fromVC.dimmingBackgroundAlpha
        sourceView.isHidden = true
        fromVC.view.isHidden = true
      
        // Animate to the final state.
        SharedElementAnimator.animate {
            sourceImageView.frame = absoluteTargetViewFrame
            self.maskingView.frame = sourceImageView.convert(absoluteTargetViewFrame, from: nil)
            self.maskingView.layer.cornerRadius = targetView.layer.cornerRadius
            self.dimmingBackgroundView.alpha = 0
        } completion: { isComplete in
            targetView.isHidden = !isComplete
            transitionContext.completeTransition(isComplete)
        }
    }
}

// MARK: - UIViewController Animated Transitioning

extension SharedElementTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        SharedElementAnimator.Constants.transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        /// Get the `from` and `to` view controllers.
        guard let fromVC = transitionContext.viewController(forKey: .from) as? SharedElementTransitionable,
              let toVC = transitionContext.viewController(forKey: .to) as? SharedElementTransitionable
        else { return }
        
        /// Get the `sharedElementView`.
        let sourceView = fromVC.sharedElementView
        let targetView = toVC.sharedElementView
        
        /// Need to layout `toVC` to get the final view frame.
        toVC.view.layoutIfNeeded()
        
        /// Calculate the absolute frames in respect to the window.
        guard let absoluteSourceViewFrame = sourceView.superview?.convert(sourceView.frame, to: nil),
              let absoluteTargetViewFrame = targetView.superview?.convert(targetView.frame, to: nil),
              let targetImageView = targetView as? UIImageView
        else { return }
        
        /// Create a copy of the `sourceView` and apply a mask to it. This is the view will be animated to the final state.
        let sourceImageView = UIImageView(image: (sourceView as? UIImageView)?.image)
        sourceImageView.mask = maskingView
        
        /// Add the views to the `transitionContext`'s `containerView`
        let containerView = transitionContext.containerView
        containerView.addSubview(dimmingBackgroundView)
        containerView.addSubview(sourceImageView)
        
        if transitionMode == .present {
            animatePresentation(
                sourceView: sourceView,
                absoluteSourceViewFrame: absoluteSourceViewFrame,
                sourceImageView: sourceImageView,
                absoluteTargetViewFrame: absoluteTargetViewFrame,
                targetImageView: targetImageView,
                transitionContext: transitionContext
            )

        } else {
            animateDismissal(
                sourceView: sourceView,
                absoluteSourceViewFrame: absoluteSourceViewFrame,
                sourceImageView: sourceImageView,
                targetView: targetView,
                absoluteTargetViewFrame: absoluteTargetViewFrame,
                targetImageView: targetImageView,
                transitionContext: transitionContext
            )
        }
    }
}
