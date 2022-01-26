//
//  ZHCirclePath.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/19.
//

import UIKit

class ZHCirclePath: ZHBasePath {
    override func draw(to point: CGPoint) {
        guard let firstP = markPoints.first else { return }
        removeAllPoints()
        let center = CGPoint(x: (firstP.x + point.x)/2, y: (firstP.y + point.y)/2)
        let radius: CGFloat = sqrt(pow((firstP.x - point.x), 2) + pow((firstP.y - point.y), 2))/2
        addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        markPoints = [firstP, point]
    }
}
