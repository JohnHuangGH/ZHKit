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
    
    override func draw() {
        stroke()
    }
}
