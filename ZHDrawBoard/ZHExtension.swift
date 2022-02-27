//
//  ZHExtension.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/21.
//

import UIKit

extension CAShapeLayer {
    /// 虚线框
    class func zh_DashlineBox(frame: CGRect, cornerRadius: CGFloat = 0, lineLength: Int = 5, lineSpacing: Int = 5, lineWidth: CGFloat = 2, color: UIColor = .black) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.bounds = CGRect.init(origin: .zero, size: frame.size)
        layer.position = CGPoint(x: frame.width/2.0, y: frame.height/2.0)
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = color.cgColor
        layer.lineWidth = lineWidth
        layer.lineJoin = .round
        layer.lineDashPattern = [NSNumber(value: lineLength), NSNumber(value: lineSpacing)]
        
        let path = UIBezierPath.init(roundedRect: frame, cornerRadius: cornerRadius)
        layer.path = path.cgPath
        
        return layer
    }
}

extension UIColor {
    /// 随机颜色
    class func zh_Random() -> UIColor {
        return UIColor(red: CGFloat(Int.random(in: 0...255))/255.0,
                       green: CGFloat(Int.random(in: 0...255))/255.0,
                       blue: CGFloat(Int.random(in: 0...255))/255.0,
                       alpha: 1)
    }
    /// 16进制Color
    class func zh_hex(_ hexStr: String) -> UIColor {
        guard !hexStr.isEmpty && hexStr.hasPrefix("#") && hexStr.count == 7 else { return .white }
        
        let hexString = hexStr.replacingOccurrences(of: "#", with: "")
        var hex: UInt64 = 0
        Scanner.init(string: hexString).scanHexInt64(&hex)
        
        return UIColor(red: CGFloat((hex & 0xff0000) >> 16) / 255.0,
                       green: CGFloat((hex & 0x00ff00) >> 8) / 255.0,
                       blue: CGFloat((hex & 0x0000ff)) / 255.0,
                       alpha: 1)
    }
}

extension UIResponder {
    /// 最近响应的VC
    func zh_CurrentVC() -> UIViewController? {
        guard let nextResponder = self.next else { return nil }
        if let vc = nextResponder as? UIViewController {
            return vc
        }else{
            return nextResponder.zh_CurrentVC()
        }
    }
}

extension Array where Self.Element == CGRect {
    /// 所有rect的边界rect
    func zh_RectsBoundingBox() -> CGRect {
        guard let firstR = self.first else { return .zero }
        var xMin: CGFloat = firstR.minX
        var yMin: CGFloat = firstR.minY
        var xMax: CGFloat = firstR.maxX
        var yMax: CGFloat = firstR.maxY
        self.forEach {
            xMin = $0.minX < xMin ? $0.minX : xMin
            yMin = $0.minY < yMin ? $0.minY : yMin
            xMax = $0.maxX > xMax ? $0.maxX : xMax
            yMax = $0.maxY > yMax ? $0.maxY : yMax
        }
        return CGRect(x: xMin, y: yMin, width: xMax - xMin, height: yMax - yMin)
    }
}

extension UIImage {
    /// 纯色图片
    class func zh_PureColorImage(color: UIColor, size: CGSize) -> UIImage {
        return zh_Image(color: color, size: size)
    }
    
    /// 生成一张图片
    class func zh_Image(color: UIColor, size: CGSize, cornerRadius: CGFloat = 0, borderWidth: CGFloat = 0, borderColor: UIColor = .clear) -> UIImage {
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
    class func zh_ScreenShot() -> UIImage? {
        guard let window = UIApplication.shared.windows.first else { return nil }
        return zh_Shot(view: window)
    }
    
    /// 视图快照
    class func zh_Shot(view: UIView) -> UIImage? {
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
