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
    
    /// 纯色图片
    class func zh_pureColorImage(color: UIColor, size: CGSize) -> UIImage {
        return zh_image(color: color, size: size)
    }
    
    /// 生成一张图片
    class func zh_image(color: UIColor, size: CGSize, cornerRadius: CGFloat = 0, borderWidth: CGFloat = 0, borderColor: UIColor = .clear) -> UIImage {
        let imgSize = CGSize(width: size.width + borderWidth * 2, height: size.height + borderWidth * 2)
        UIGraphicsBeginImageContextWithOptions(imgSize, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        let path = UIBezierPath(roundedRect: CGRect(x: borderWidth, y: borderWidth, width: size.width, height: size.height), cornerRadius: cornerRadius)
        color.setFill()
        path.fill()
        let borderPath =  UIBezierPath(roundedRect: CGRect(origin: .zero, size: imgSize), cornerRadius: cornerRadius + borderWidth)
        borderColor.setFill()
        borderPath.fill()
        borderPath.append(path)
        context?.addPath(borderPath.cgPath)
        context?.fillPath()
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 屏幕截图
    class func zh_screenShot() -> UIImage? {
        guard let window = UIApplication.shared.windows.first else { return nil }
        return zh_shot(view: window)
    }
    
    /// 视图快照
    class func zh_shot(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        let success = view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)//快照渲染到上下文
        if !success {
            view.layer.render(in: UIGraphicsGetCurrentContext()!)//layer渲染到上下文
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
