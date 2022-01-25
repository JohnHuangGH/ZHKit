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

extension CGPath {
    func forEach( body: @escaping @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        //print(MemoryLayout.size(ofValue: body))
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
    }
    func getPathElementsPoints() -> [CGPoint] {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
            default: break
            }
        }
        return arrayPoints
    }
    func getPathElementsPointsAndTypes() -> ([CGPoint],[CGPathElementType]) {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        var arrayTypes : [CGPathElementType]! = [CGPathElementType]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            default: break
            }
        }
        return (arrayPoints,arrayTypes)
    }
}
