//
//  UIView+Draw.swift
//
//  Created by Zeng Guojie on 26/5/2017.
//  Copyright © 2017 Innopage Limited. All rights reserved.
//

import UIKit

extension UIView {
    func addMask(path: UIBezierPath) {
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func setRoundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func addRoundCorners(_ corners:UIRectCorner, radius: CGFloat, borderColor: CGColor, borderWidth: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        
        let shape = CAShapeLayer()
        shape.frame = bounds
        shape.path = path.cgPath
        shape.lineWidth = borderWidth
        shape.strokeColor = borderColor
        shape.fillColor = UIColor.clear.cgColor
        layer.addSublayer(shape)
    }
    
    func setShadow(color: UIColor? = nil, opacity: Float = 0.2, offset: CGSize? = nil, radius: CGFloat? = nil) {
        clipsToBounds = false
        if let color = color {
            layer.shadowColor = color.cgColor
        }
        
        layer.shadowOpacity = opacity
        
        if let offset = offset {
            layer.shadowOffset = offset
        }
        if let radius = radius {
            layer.shadowRadius = radius
        }
    }
    
    /// If the view uses auto layout, need to call `setNeedsLayout()` and `layoutIfNeeded()` to layout subviews before calling this method.
    var renderedImage: UIImage {
        let render = UIGraphicsImageRenderer(bounds: bounds)
        return render.image { (context) in
            layer.render(in: context.cgContext)
        }
    }
}

extension UIBezierPath {
    static func roundedPolygonPath(rect: CGRect, lineWidth: CGFloat, sides: Int, cornerRadius: CGFloat, rotationOffset: CGFloat = 0) -> UIBezierPath {
        let path = UIBezierPath()
        let theta = CGFloat(2.0 * .pi) / CGFloat(sides) // How much to turn at every corner
//        let offset: CGFloat = cornerRadius * tan(theta / 2.0)     // Offset from which to start rounding corners
        let width = min(rect.size.width, rect.size.height)        // Width of the square
        
        let center = CGPoint(x: rect.origin.x + width / 2.0, y: rect.origin.y + width / 2.0)
        
        // Radius of the circle that encircles the polygon
        // Notice that the radius is adjusted for the corners, that way the largest outer
        // dimension of the resulting shape is always exactly the width - linewidth
        let radius = (width - lineWidth + cornerRadius - (cos(theta) * cornerRadius)) / 2.0
        
        // Start drawing at a point, which by default is at the right hand edge
        // but can be offset
        var angle = CGFloat(rotationOffset)
        
        let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
        path.move(to: CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta)))
        
        for _ in 0..<sides {
            angle += theta
            
            let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
            let tip = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            let start = CGPoint(x: corner.x + cornerRadius * cos(angle - theta), y: corner.y + cornerRadius * sin(angle - theta))
            let end = CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta))
            
            path.addLine(to: start)
            path.addQuadCurve(to: end, controlPoint: tip)
        }
        
        path.close()
        
        // Move the path to the correct origins
        let bounds = path.bounds
        let transform = CGAffineTransform(translationX: -bounds.origin.x + rect.origin.x + lineWidth / 2.0, y: -bounds.origin.y + rect.origin.y + lineWidth / 2.0)
        path.apply(transform)
        
        return path
    }
}

