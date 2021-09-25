//
//  SecondVC.swift
//  shared-element-transition-demo
//
//  Created by Victor Samuel Cuaca on 25/09/21.
//

import UIKit

class SecondVC: UIViewController {
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Close", for: .normal)
        button.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "journey"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
        
    // MARK: - Variables
    
    private var didSetupConstraints = false
    private var imageViewOriginalCenter: CGPoint = .zero
    private var backgroundViewAlpha: CGFloat = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        view.backgroundColor = .black
        view.setNeedsUpdateConstraints()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        view.addGestureRecognizer(pan)
    }
    
    override func updateViewConstraints() {
        defer { super.updateViewConstraints() }
        guard !didSetupConstraints else { return }
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        didSetupConstraints = true
    }
    
    // MARK: - Private Functions
    
    private func setupSubviews() {
        view.addSubview(closeButton)
        view.addSubview(imageView)
    }
    
    // MARK: - Action Handlers
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    @objc private func didPan(_ gesture: UIPanGestureRecognizer) {
        func getProgress() -> CGFloat {
            let origin = imageViewOriginalCenter
            let changeX = abs(imageView.center.x - origin.x)
            let changeY = abs(imageView.center.y - origin.y)
            let progressX = changeX / view.bounds.width
            let progressY = changeY / view.bounds.height
            return max(progressX, progressY)
        }
        
        func getCenterChange() -> CGPoint {
            let origin = imageView.center
            let change = gesture.translation(in: view)
            return CGPoint(x: origin.x + change.x, y: origin.y + change.y)
        }
                
        func getVelocity() -> CGFloat {
            let vel = gesture.velocity(in: view)
            return sqrt(vel.x * vel.x + vel.y * vel.y)
        }
        
        switch gesture.state {
        case .began:
            imageViewOriginalCenter = imageView.center
            closeButton.isHidden = true
            
        case .changed:
            let progress = getProgress()
            let inverseProgress = 1 - progress
            let scale = max(inverseProgress, 0.7)
            let dimmingAlpha = max(inverseProgress, 0.7)
            let cornerRadius = min(progress * 100, 10)
            
            imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
            imageView.center = getCenterChange()
            imageView.roundCornersForAspectFit(radius: cornerRadius)
            
            backgroundViewAlpha = dimmingAlpha
            view.backgroundColor = view.backgroundColor?.withAlphaComponent(backgroundViewAlpha)
            
            gesture.setTranslation(.zero, in: nil)
            
        case .ended:
            if getProgress() > 0.25 || getVelocity() > 1000 {
                dismiss(animated: true)
            } else {
                // Animate back to original position.
                UIView.animate(withDuration: 0.3) {
                    self.imageView.center = self.imageViewOriginalCenter
                    self.imageView.transform = .identity
                    self.imageView.roundCornersForAspectFit(radius: 0)
                    self.view.backgroundColor = .black
                } completion: { _ in
                    self.imageViewOriginalCenter = .zero
                    self.backgroundViewAlpha  = 1.0
                    self.closeButton.isHidden = false
                }
            }
            
        default:
            break
        }
    }
}

extension SecondVC: SharedElementTransitionable {
    var sharedElementView: UIView { imageView }
    var dimmingBackgroundAlpha: CGFloat { backgroundViewAlpha }
}
