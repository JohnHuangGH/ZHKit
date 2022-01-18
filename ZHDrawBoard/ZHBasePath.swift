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
        
        move(to: point)
    }
    
    override func move(to point: CGPoint) {
        markPoints.append(point)
        super.move(to: point)
    }
}
