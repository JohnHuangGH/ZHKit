//
//  ZHLinePath.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/18.
//

import UIKit

class ZHLinePath: ZHBasePath {

    func drawLine(to point: CGPoint) {
        guard let firstP = markPoints.first else { return }
        removeAllPoints()
        move(to: firstP)
        addLine(to: point)
        markPoints[1] = point
    }
}
