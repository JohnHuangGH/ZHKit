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
    var isFill: Bool = false
    
    /// 已结束绘制（或超出画板）
    var isFinish: Bool = false
    /// 是否正在选中
    var isSelectedPath: Bool = false
    /// 是否有效的，正常绘制的，非缩放产生的
    var isValid: Bool = false
    /// 是否已移动
    var moved: Bool = false
    /// 移动前的path
    var preMovePath: ZHBasePath?
    /// 已删除
    var isDeleted: Bool = false

    
    convenience init(width: CGFloat, color: UIColor, capStyle: CGLineCap = .round, joinStyle: CGLineJoin = .round) {
        self.init()
        lineWidth = width
        lineColor = color
        lineCapStyle = capStyle
        lineJoinStyle = joinStyle
    }
    
    convenience init(width: CGFloat, color: UIColor, point: CGPoint, capStyle: CGLineCap = .round, joinStyle: CGLineJoin = .round) {
        self.init(width: width, color: color, capStyle: capStyle, joinStyle: joinStyle)
        
        begin(to: point)
    }
    
    func offset(to point: CGPoint) {
        removeAllPoints()
        let points = markPoints
        markPoints.removeAll()
        for (idx, p) in points.enumerated() {
            let offsetP = CGPoint(x: p.x + point.x, y: p.y + point.y)
            idx == 0 ? begin(to: offsetP) : draw(to: offsetP)
        }
    }
    
    func copyPath() -> Self {
        guard let path = self.copy() as? Self else { return self }
        path.lineColor = lineColor
        path.markPoints = markPoints
        path.isFill = isFill
        return path
    }
    
    func deleted(){
        isDeleted = true
        guard let prePath = preMovePath else { return }
        prePath.deleted()
    }
    
    override func stroke() {
        lineColor.set()
        super.stroke()
    }
    
    override func fill() {
        lineColor.set()
        super.fill()
    }
    
    func begin(to point: CGPoint) {
        markPoints.append(point)
        move(to: point)
    }
    /// draw(_ rect: CGRect)中调用此方法进行绘制
    func draw() {
        isFill ? fill() : stroke()
    }
    
    /// 由子类实现
    func draw(to point: CGPoint) {}
}
