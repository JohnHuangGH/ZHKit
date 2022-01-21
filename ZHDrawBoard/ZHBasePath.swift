//
//  ZHBasePath.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/13.
//

import UIKit

class ZHBasePath: UIBezierPath {
    
    var lineColor: UIColor = .black
    var markPoints: [CGPoint] = []
    var isSelectedPath: Bool = false
    
    var isValid: Bool = false //有效的，正常绘制的，非缩放产生的
    
    var preMovePath: ZHBasePath?
    var moved: Bool = false

    
    convenience init(width: CGFloat, color: UIColor, capStyle: CGLineCap = .round, joinStyle: CGLineJoin = .round) {
        self.init()
        lineWidth = width
        lineColor = color
        lineCapStyle = capStyle
        lineJoinStyle = joinStyle
    }
    
    convenience init(width: CGFloat, color: UIColor, point: CGPoint, capStyle: CGLineCap = .round, joinStyle: CGLineJoin = .round) {
        self.init(width: width, color: color, capStyle: capStyle, joinStyle: joinStyle)
        
        begin(to: point)
    }
    
    func offset(to point: CGPoint) -> Self {
        guard let path = self.copy() as? ZHBasePath else { return self }
        path.lineColor = lineColor
        
        path.removeAllPoints()
        for (idx, p) in markPoints.enumerated() {
            let offsetP = CGPoint(x: p.x + point.x, y: p.y + point.y)
            idx == 0 ? path.begin(to: offsetP) : path.draw(to: offsetP)
        }
        
        return path as! Self
    }
    
    func copyPath() -> Self {
        guard let path = self.copy() as? ZHBasePath else { return self }
        path.lineColor = lineColor
        path.markPoints = markPoints
        path.isSelectedPath = isSelectedPath
        path.isValid = isValid
        path.preMovePath = preMovePath
        path.moved = moved
        return path as! Self
    }
    
    override func stroke() {
        lineColor.set()
        super.stroke()
    }
    
    override func fill() {
        lineColor.set()
        super.fill()
    }
    
    func begin(to point: CGPoint) {
        markPoints.append(point)
        move(to: point)
    }
    
    /// 由子类实现
    func draw(to point: CGPoint) {}
    
    func draw() {}
}
