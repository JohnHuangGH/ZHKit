//
//  ZHArrowPath.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/20.
//

import UIKit

class ZHArrowPath: ZHBasePath {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        self.isFill = true
    }
    
    override func draw(to p1: CGPoint) {
        guard let p0 = markPoints.first, p0 != p1 else { return }
        removeAllPoints()
        
        var p2: CGPoint = .zero
        var p3: CGPoint = .zero
        var p4: CGPoint = .zero
        var p5: CGPoint = .zero
        var p6: CGPoint = .zero
        
        let line01 = sqrt(pow((p0.x - p1.x), 2) + pow((p0.y - p1.y), 2))
        let line01X = sqrt(pow((p0.x - p1.x), 2))
        let line01Y = sqrt(pow((p0.y - p1.y), 2))
        let line12 = lineWidth * 2
//        let line12 = line01 * 0.1
        let line12X = line12 / line01 * line01X
        let line12Y = line12 / line01 * line01Y
        let line23 = line12
        let line24 = line12
        let line02 = line01 - line12
        let line23X = line23 / line02 * (line01Y - line12Y)
        let line23Y = line23 / line02 * (line01X - line12X)
        let line24X = line24 / line02 * (line01Y - line12Y)
        let line24Y = line24 / line02 * (line01X - line12X)
        
        if p0.x < p1.x {
            if p0.y < p1.y {
                p2 = CGPoint(x: p1.x - line12X, y: p1.y - line12Y)
                p3 = CGPoint(x: p2.x - line23X, y: p2.y + line23Y)
                p4 = CGPoint(x: p2.x + line24X, y: p2.y - line24Y)
                p5 = CGPoint(x: p2.x - line23X/2, y: p2.y + line23Y/2)
                p6 = CGPoint(x: p2.x + line24X/2, y: p2.y - line24Y/2)
            }else{
                p2 = CGPoint(x: p1.x - line12X, y: p1.y + line12Y)
                p3 = CGPoint(x: p2.x + line23X, y: p2.y + line23Y)
                p4 = CGPoint(x: p2.x - line24X, y: p2.y - line24Y)
                p5 = CGPoint(x: p2.x + line23X/2, y: p2.y + line23Y/2)
                p6 = CGPoint(x: p2.x - line24X/2, y: p2.y - line24Y/2)
            }
        }else{
            if p0.y < p1.y {
                p2 = CGPoint(x: p1.x + line12X, y: p1.y - line12Y)
                p3 = CGPoint(x: p2.x - line23X, y: p2.y - line23Y)
                p4 = CGPoint(x: p2.x + line24X, y: p2.y + line24Y)
                p5 = CGPoint(x: p2.x - line23X/2, y: p2.y - line23Y/2)
                p6 = CGPoint(x: p2.x + line24X/2, y: p2.y + line24Y/2)
            }else{
                p2 = CGPoint(x: p1.x + line12X, y: p1.y + line12Y)
                p3 = CGPoint(x: p2.x + line23X, y: p2.y - line23Y)
                p4 = CGPoint(x: p2.x - line24X, y: p2.y + line24Y)
                p5 = CGPoint(x: p2.x + line23X/2, y: p2.y - line23Y/2)
                p6 = CGPoint(x: p2.x - line24X/2, y: p2.y + line24Y/2)
            }
        }
        
        move(to: p0)
        addLine(to: p5)
        addLine(to: p3)
        addLine(to: p1)
        addLine(to: p4)
        addLine(to: p6)
        addLine(to: p0)
        markPoints = [p0, p1]
    }
}
