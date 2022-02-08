//
//  ZHExtension.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/21.
//

import UIKit

extension CAShapeLayer {
    /// 虚线框
    class func zh_DrawDashRect(frame: CGRect, cornerRadius: CGFloat = 0, lineLength: Int = 5, lineSpacing: Int = 5, lineWidth: CGFloat = 2, color: UIColor = .black) -> CAShapeLayer {
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
    class func zh_RandomColor() -> UIColor {
        return UIColor(red: CGFloat(Int.random(in: 0...255))/255.0,
                       green: CGFloat(Int.random(in: 0...255))/255.0,
                       blue: CGFloat(Int.random(in: 0...255))/255.0,
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
    func zh_ScreenShot() -> UIImage? {
        //截取整个屏幕
        guard let window = UIApplication.shared.windows.first else { return nil }
        // 用下面这行而不是UIGraphicsBeginImageContext()，因为前者支持Retina
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0.0)
        window.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
       
//        return UIImage.init(data: image?.jpegData(compressionQuality: 0.5) ?? Data()) //image
        return image
    }
}
