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
    
    func convertFrame(in rect: CGRect, to targetContentMode: UIView.ContentMode) -> CGRect {
        guard let imageSize = image?.size,
              contentMode != targetContentMode else { return .zero }
        
        let wRatio = rect.size.width / imageSize.width
        let hRatio = rect.size.height / imageSize.height
        
        let w: CGFloat
        let h: CGFloat
        
        switch targetContentMode {
        case .scaleAspectFit:
            let r = min(wRatio, hRatio)
            w = imageSize.width * r
            h = imageSize.height * r
                        
        case .scaleAspectFill:
            let r = max(wRatio, hRatio)
            w = imageSize.width * r
            h = imageSize.height * r
            
        default:
            return rect
        }
        
        return CGRect(
            x: rect.origin.x - (w - rect.width) / 2,
            y: rect.origin.y - (h - rect.height) / 2,
            width: w,
            height: h
        )
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
