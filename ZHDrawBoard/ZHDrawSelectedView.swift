//
//  ZHDrawSelectedView.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/17.
//

import UIKit

class ZHDrawSelectedView: UIView {
    
    var movedHandle: ((_ selectedView: ZHDrawSelectedView)->Void)?
    
    var selectedPaths: [ZHBasePath] = []
    var showPaths: [ZHBasePath] = []
    private var showBgPaths: [ZHBasePath] = []
    
    var originalRect: CGRect = .zero
    var movedRect: CGRect = .zero
    
    convenience init(path: ZHBasePath) {
        let isArrowPath = path.isKind(of: ZHArrowPath.self)
        let selPathLineW = isArrowPath ? 0 : path.lineWidth//箭头是fill
        let selBgPathLineW: CGFloat = 4
        let dashLineW: CGFloat = 2
        
        let pathRect = path.cgPath.boundingBoxOfPath //boundingBox包括控制点，boundingBoxOfPath不包括控制点（这里圆的绘制起始点不固定，或许跟控制点相关？用boundingBoxOfPath更为准确）
        let viewX = pathRect.origin.x - (selPathLineW + selBgPathLineW + dashLineW) * 0.5
        let viewY = pathRect.origin.y - (selPathLineW + selBgPathLineW + dashLineW) * 0.5
        let viewW = pathRect.size.width + selPathLineW + selBgPathLineW + dashLineW
        let viewH = pathRect.size.height + selPathLineW + selBgPathLineW + dashLineW
        let viewRect = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        
        self.init(frame: viewRect)
        selectedPaths.append(path)
        originalRect = viewRect
        backgroundColor = .clear
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(recognizer:)))
        addGestureRecognizer(pan)
        
        let offset = CGPoint(x: -viewRect.origin.x, y: -viewRect.origin.y)
        
        let showBgPath = path.offset(to: offset)
        showBgPath.lineWidth = selPathLineW + selBgPathLineW
        showBgPath.lineColor = .red
        showBgPaths.append(showBgPath)
        
        let showPath = path.offset(to: offset)
        showPaths.append(showPath)
        
        
        let dashRect = CGRect(x: 0, y: 0, width: viewW, height: viewH)
        let dashRectLayer = CAShapeLayer.zh_DrawDashRect(frame: dashRect, lineWidth: dashLineW, color: .red)
        layer.addSublayer(dashRectLayer)
    }
    
    convenience init(paths: [ZHMarkPath]) {
        self.init()
        backgroundColor = .clear
        
        showPaths = paths
        
        
    }
    
    override func draw(_ rect: CGRect) {
        for (idx, showPath) in showPaths.enumerated() {
            let showBgPath = showBgPaths[idx]
            showBgPath.isKind(of: ZHArrowPath.self) ? showBgPath.stroke() : showBgPath.draw()
            
            showPath.draw()
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
        if recognizer.state == .ended {
            movedHandle?(self)
        }
    }
    
    func reset(){
        self.frame = originalRect
    }
}
