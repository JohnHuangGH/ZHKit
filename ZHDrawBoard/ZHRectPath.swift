//
//  ZHRectPath.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/20.
//

import UIKit

class ZHRectPath: ZHBasePath {
    override func draw(to point: CGPoint) {
        guard let firstP = markPoints.first else { return }
        removeAllPoints()
        let p1 = CGPoint(x: point.x, y: firstP.y)
        let p2 = CGPoint(x: firstP.x, y: point.y)
        move(to: firstP)
        addLine(to: p1)
        addLine(to: point)
        addLine(to: p2)
        addLine(to: firstP)
        markPoints = [firstP, point]
    }
    
    override func draw() {
        stroke()
    }
}
