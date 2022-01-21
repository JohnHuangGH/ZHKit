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
    class func zh_RandomColor() -> UIColor {
        return UIColor(red: CGFloat(Int.random(in: 0...255))/255.0,
                       green: CGFloat(Int.random(in: 0...255))/255.0,
                       blue: CGFloat(Int.random(in: 0...255))/255.0,
                       alpha: 1)
    }
}
