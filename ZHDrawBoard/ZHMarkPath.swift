//
//  ZHMarkPath.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/13.
//

import UIKit

class ZHMarkPath: ZHBasePath {
    
    override func addLine(to point: CGPoint) {
        markPoints.append(point)
        super.addLine(to: point)
    }
    
    convenience init(width: CGFloat, color: UIColor, points: [CGPoint], offset: CGPoint, capStyle: CGLineCap = .round, joinStyle: CGLineJoin = .round) {
        self.init(width: width, color: color, capStyle: capStyle, joinStyle: joinStyle)
    
        for (idx, point) in points.enumerated() {
            let p = CGPoint(x: point.x + offset.x, y: point.y + offset.y)
            idx == 0 ? move(to: p) : addLine(to: p)
        }
    }
    
//    func clickRect() -> CGRect {
//        if markPoints.count < 2 { return .zero }
//        guard let fristP = markPoints.first else { return .zero }
//        var xMin: CGFloat = fristP.x
//        var yMin: CGFloat = fristP.y
//        var xMax: CGFloat = fristP.x
//        var yMax: CGFloat = fristP.y
//        markPoints.forEach { p in
//            xMin = p.x < xMin ? p.x : xMin
//            yMin = p.y < yMin ? p.y : yMin
//            xMax = p.x > xMax ? p.x : xMax
//            yMax = p.y > yMax ? p.y : yMax
//        }
//        return CGRect(x: xMin, y: yMin, width: xMax-xMin, height: yMax-yMin)
//    }
}
