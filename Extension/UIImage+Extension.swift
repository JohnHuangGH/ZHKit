//
//  UIImage+Extension.swift
//  shineline
//
//  Created by QuanHuan on 2021/6/1.
//

import UIKit

extension UIImage {

    enum ZHGradientType {
        case topToBottom
        case leftToRight
        case topLeftToBottomRight
        case topRightToBottomLeft
    }
    /// 生成渐变色图片
    /// - Parameters:
    ///   - type: 渐变方向
    ///   - colors: 开始颜色，终止颜色，以及过度色
    ///   - locations: 每个颜色在渐变色中的位置，值介于0.0-1.0之间
    ///   - size: 图片大小
    class func zh_gradientImage(type: ZHGradientType, colors: [UIColor], locations: [CGFloat], size: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let cgColors = colors.compactMap { $0.cgColor }

        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: locations) else { return UIImage() }
        
        switch type {
        case .leftToRight:
            context?.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: 0), options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
        case .topToBottom:
            context?.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: size.height), options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
        case .topLeftToBottomRight:
            context?.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: size.height), options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
        case .topRightToBottomLeft:
            context?.drawLinearGradient(gradient, start: CGPoint(x: size.width, y: 0), end: CGPoint(x: 0, y: size.height), options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
        }
        
        let tempImg = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        context?.restoreGState()
        UIGraphicsEndImageContext()
        guard let newImg = tempImg else { return UIImage() }
        return UIImage(cgImage: newImg)
    }
    
    /// 图片裁切圆角
    func zh_image(cornerRadius radius: CGFloat) -> UIImage {
        
        let rect = CGRect.init(origin: .zero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.addPath(UIBezierPath.init(roundedRect: rect, cornerRadius: radius).cgPath)
            context.clip()
            self.draw(in: rect)
            
            if let newImg = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                return newImg
            }
        }
        
        UIGraphicsEndImageContext()
        return self
    }
}
