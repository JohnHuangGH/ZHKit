//
//  CALayer+Extension.swift
//  shineline
//
//  Created by QuanHuan on 2021/3/31.
//

import UIKit

extension CAShapeLayer {
    /// 虚线
    class func zh_DrawDashLine(frame: CGRect, lineLength: Int, lineSpacing: Int, color: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.bounds = CGRect.init(origin: .zero, size: frame.size)
        layer.position = CGPoint(x: frame.width/2.0, y: frame.height/2.0)
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = color.cgColor
        layer.lineWidth = frame.height < frame.width ? frame.height : frame.width
        layer.lineJoin = .round
        layer.lineDashPattern = [NSNumber(value: lineLength), NSNumber(value: lineSpacing)]

        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: frame.width, y: frame.height))
        layer.path = path

        return layer
    }
    
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
    
    /// 圆角
    class func zh_RoundingCorners(frame: CGRect, corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let path = UIBezierPath.init(roundedRect: frame, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        layer.path = path.cgPath
        return layer
    }
    
    /// 挖孔遮罩
    class func zh_DrawEvenOddMask(maskRect: CGRect, clearRect: CGRect, cornerRadius: CGFloat, _ color: UIColor = UIColor(white: 0, alpha: 0.5)) -> CAShapeLayer {
        let maskPath = UIBezierPath(rect: maskRect)
        let clearPath = UIBezierPath(roundedRect: clearRect, cornerRadius: cornerRadius)
        maskPath.append(clearPath)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = color.cgColor
        
        return maskLayer
    }
}

extension CAGradientLayer {
    /// 渐变
    class func zh_DrawGradient(_ width: CGFloat, _ height: CGFloat, _ colors: [CGColor], _ startX: CGFloat = 0, _ startY: CGFloat = 0, _ endX: CGFloat = 0, _ endY: CGFloat = 0, _ locations: [NSNumber] = [0, 1]) -> CAGradientLayer {
        let gl = CAGradientLayer()
        gl.frame = CGRect(x: 0, y: 0, width: width, height: height)
        gl.colors = colors
        gl.startPoint = CGPoint(x: startX, y: startY)
        gl.endPoint = CGPoint(x: endX, y: endY)
        gl.locations = locations
        return gl
    }
}
