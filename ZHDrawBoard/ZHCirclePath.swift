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
//        move(to: firstP)
        let center = CGPoint(x: (firstP.x + point.x)/2, y: (firstP.y + point.y)/2)
        let radius: CGFloat = sqrt(pow((firstP.x - point.x), 2) + pow((firstP.y - point.y), 2))/2
//        var startAngle: CGFloat = 0
//
//        let x = sqrt(pow((firstP.x - point.x), 2))
//        let y = sqrt(pow((firstP.y - point.y), 2))
//        if firstP.x < point.x {
//            if firstP.y < point.y {
//                startAngle = .pi * 1 + atan2(y, x)
//            }else{
//                startAngle = .pi * 1 - atan2(y, x)
//            }
//        }else{
//            if firstP.y < point.y {
//                startAngle = .pi * 0 - atan2(y, x)
//            }else{
//                startAngle = .pi * 0 + atan2(y, x)
//            }
//        }
//        addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: startAngle + .pi * 2, clockwise: true)
        addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        markPoints = [firstP, point]
    }
    
    override func draw() {
        stroke()
    }
}
