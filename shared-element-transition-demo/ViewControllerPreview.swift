//
//  ViewControllerPreview.swift
//  shared-element-transition-demo
//
//  Created by Victor Samuel Cuaca on 02/10/21.
//

#if DEBUG
import SwiftUI

@available (iOS 13.0, *)
struct ViewControllerPreview: UIViewControllerRepresentable {
    let makeViewController: () -> UIViewController
    
    init(_ makeViewController: @escaping () -> UIViewController) {
        self.makeViewController = makeViewController
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        makeViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
#endif
