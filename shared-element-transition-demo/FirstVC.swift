//
//  FirstVC.swift
//  shared-element-transition-demo
//
//  Created by Victor Samuel Cuaca on 25/09/21.
//

import UIKit

class FirstVC: UIViewController {
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "journey"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    // MARK: - Variables
    
    private var didSetupConstraints = false

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        view.backgroundColor = .white
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        defer { super.updateViewConstraints() }
        guard !didSetupConstraints else { return }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),

            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 400),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -400),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
        
        didSetupConstraints = true
    }
    
    // MARK: - Private Functions
    
    private func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        imageView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Action Handlers
    
    @objc private func didTapImage() {
        let secondVC = SecondVC()
        secondVC.transitioningDelegate = self
        secondVC.modalPresentationStyle = .overCurrentContext
        present(secondVC, animated: true)
    }
}

extension FirstVC: SharedElementTransitionable {
    var sharedElementView: UIView { imageView }
}

extension FirstVC: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SharedElementTransition(transitionMode: .present)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SharedElementTransition(transitionMode: .dismiss)
    }
}
