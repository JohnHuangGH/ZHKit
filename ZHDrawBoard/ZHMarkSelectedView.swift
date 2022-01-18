//
//  ZHMarkSelectedView.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/17.
//

import UIKit

class ZHMarkSelectedView: UIView {
    
    var selectedPath: ZHBasePath?
    var originalRect: CGRect = .zero
    var paths: [ZHBasePath] = []
    var movedRect: CGRect = .zero
    
    convenience init(path: ZHBasePath) {
        let selPathLineW = path.lineWidth
        let selBgPathLineW: CGFloat = 4
        let dashLineW: CGFloat = 2
        
        let pathRect = path.cgPath.boundingBox
        let viewX = pathRect.origin.x - selPathLineW - dashLineW * 0.5
        let viewY = pathRect.origin.y - selPathLineW - dashLineW * 0.5
        let viewW = pathRect.size.width + selBgPathLineW * 2 + dashLineW
        let viewH = pathRect.size.height + selBgPathLineW * 2 + dashLineW
        let viewRect = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        
        self.init(frame: viewRect)
        selectedPath = path
        originalRect = viewRect
        backgroundColor = .clear
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(recognizer:)))
        addGestureRecognizer(pan)
        
        let offset = CGPoint(x: -viewRect.origin.x, y: -viewRect.origin.y)
        let selPath = ZHMarkPath(width: selPathLineW, color: path.lineColor, points: path.markPoints, offset: offset)
        let selBgPath = ZHMarkPath(width: selPathLineW + selBgPathLineW, color: .red, points: path.markPoints, offset: offset)
        
        self.paths = [selBgPath, selPath]
        
        let dashRect = CGRect(x: 0, y: 0, width: viewW, height: viewH)
        let dashRectLayer = CAShapeLayer.zh_DrawDashRect(frame: dashRect, lineWidth: dashLineW, color: .red)
        layer.addSublayer(dashRectLayer)
    }
    
    convenience init(paths: [ZHMarkPath]) {
        self.init()
        backgroundColor = .clear
        
        self.paths = paths
        
        
    }
    
    override func draw(_ rect: CGRect) {
        paths.forEach {
            $0.lineColor.set()
            $0.stroke()
        }
    }
    
    var panBeginPoint: CGPoint = .zero
    @objc func panAction(recognizer: UIPanGestureRecognizer){
        if recognizer.state == .began {
            panBeginPoint = recognizer.location(in: self)
        }
        let p = recognizer.location(in: self.superview)
        var rect = self.frame
        rect.origin = CGPoint(x: p.x - panBeginPoint.x, y: p.y - panBeginPoint.y)
        movedRect = rect
        self.frame = rect
    }
    
    func reset(){
        self.frame = originalRect
    }
}
