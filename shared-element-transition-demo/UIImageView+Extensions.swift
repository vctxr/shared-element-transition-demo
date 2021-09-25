//
//  UIImageView+Extensions.swift
//  shared-element-transition-demo
//
//  Created by Victor Samuel Cuaca on 25/09/21.
//

import UIKit

extension UIImageView {
    var aspectFitFrame: CGRect {
        guard let image = image else { return .zero }
        
        let newWidth: CGFloat = frame.size.width / image.size.width
        let newHeight: CGFloat = frame.size.height / image.size.height
        
        var aspectFitSize = frame.size
        if newHeight < newWidth {
            aspectFitSize.width = newHeight * image.size.width
        } else if newWidth < newHeight {
            aspectFitSize.height = newWidth * image.size.height
        }
        
        return CGRect(
            x: (frame.size.width - aspectFitSize.width) / 2,
            y: (frame.size.height - aspectFitSize.height) / 2,
            width: aspectFitSize.width,
            height: aspectFitSize.height
        )
    }
    
    func convertFrame(from rect: CGRect, to contentMode: UIView.ContentMode) -> CGRect {
        guard let imageSize = image?.size else { return .zero }
        
        switch contentMode {
        case .scaleAspectFit:
            return rect
            
        case .scaleAspectFill:
            let r = max(rect.size.width / imageSize.width, rect.size.height / imageSize.height)
            let w = imageSize.width * r
            let h = imageSize.height * r
            
            return CGRect(
                x: rect.origin.x - (w - rect.width) / 2,
                y: rect.origin.y - (h - rect.height) / 2,
                width: w,
                height: h
            )
            
        default:
            return rect
        }
    }
    
    func roundCornersForAspectFit(radius: CGFloat) {
        guard let image = image else { return }
        
        // Calculate drawing rect.
        let boundsScale = bounds.size.width / bounds.size.height
        let imageScale = image.size.width / image.size.height
        
        var drawingRect: CGRect = bounds
        
        if boundsScale > imageScale {
            drawingRect.size.width =  drawingRect.size.height * imageScale
            drawingRect.origin.x = (bounds.size.width - drawingRect.size.width) / 2
        } else {
            drawingRect.size.height = drawingRect.size.width / imageScale
            drawingRect.origin.y = (bounds.size.height - drawingRect.size.height) / 2
        }
        
        let path = UIBezierPath(roundedRect: drawingRect, cornerRadius: radius)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        
        self.layer.mask = mask
        self.layer.cornerRadius = radius
    }
}
