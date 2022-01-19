//
//  ZHBasePath.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/13.
//

import UIKit

protocol ZHBasePathProtocol {
    func draw(to point: CGPoint)
}

class ZHBasePath: UIBezierPath, ZHBasePathProtocol {
    
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
    
    convenience init(width: CGFloat, color: UIColor, points: [CGPoint], offset: CGPoint, capStyle: CGLineCap = .round, joinStyle: CGLineJoin = .round) {
        self.init(width: width, color: color, capStyle: capStyle, joinStyle: joinStyle)
    
        for (idx, point) in points.enumerated() {
            let p = CGPoint(x: point.x + offset.x, y: point.y + offset.y)
            idx == 0 ? begin(to: p) : draw(to: p)
        }
    }
    
    func getOffsetPath(width: CGFloat, color: UIColor, offset: CGPoint) {
        
//        let path = type(of: self).init(width: width, color: color, points: markPoints, offset: offset)
//        return self
    }
    
    func begin(to point: CGPoint) {
        markPoints.append(point)
        move(to: point)
    }
    
    func draw(to point: CGPoint) {}
}
