//
//  ZHMarkPath.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/13.
//

import UIKit

class ZHMarkPath: ZHBasePath {
    
    override func draw(to point: CGPoint) {
        markPoints.append(point)
        addLine(to: point)
    }
    
//    override func addLine(to point: CGPoint) {
//        markPoints.append(point)
//        super.addLine(to: point)
//    }
    
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
