//
//  ZHMarkPath.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/13.
//

import UIKit

class ZHMarkPath: UIBezierPath {
    
    var lineColor: UIColor = .black
    var markPoints: [CGPoint] = []
    var isSelectedPath: Bool = false
    //有效的，正常绘制的，非缩放产生的
    var isValid: Bool = false
    
    convenience init(width: CGFloat, color: UIColor, point: CGPoint, capStyle: CGLineCap = .round, joinStyle: CGLineJoin = .round) {
        self.init()
        lineWidth = width
        lineColor = color
        lineCapStyle = capStyle
        lineJoinStyle = joinStyle
        
        markPoints.append(point)
        move(to: point)
    }
    
    override func addLine(to point: CGPoint) {
        markPoints.append(point)
        super.addLine(to: point)
    }
    
    func clickRect() -> CGRect {
        if markPoints.count < 2 { return .zero }
        guard let fristP = markPoints.first else { return .zero }
        var xMin: CGFloat = fristP.x
        var yMin: CGFloat = fristP.y
        var xMax: CGFloat = fristP.x
        var yMax: CGFloat = fristP.y
        markPoints.forEach { p in
            xMin = p.x < xMin ? p.x : xMin
            yMin = p.y < yMin ? p.y : yMin
            xMax = p.x > xMax ? p.x : xMax
            yMax = p.y > yMax ? p.y : yMax
        }
        return CGRect(x: xMin, y: yMin, width: xMax-xMin, height: yMax-yMin)
    }
}
