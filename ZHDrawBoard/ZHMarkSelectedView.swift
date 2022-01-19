//
//  ZHMarkSelectedView.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/17.
//

import UIKit

class ZHMarkSelectedView: UIView {
    
    var movedHandle: ((_ selectedView: ZHMarkSelectedView)->Void)?
    
    var selectedPaths: [ZHBasePath] = []
    var showPaths: [ZHBasePath] = []
    private var showBgPaths: [ZHBasePath] = []
    
    var originalRect: CGRect = .zero
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
        selectedPaths.append(path)
        originalRect = viewRect
        backgroundColor = .clear
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(recognizer:)))
        addGestureRecognizer(pan)
        
        let offset = CGPoint(x: -viewRect.origin.x, y: -viewRect.origin.y)
        
        
        if path.isKind(of: ZHMarkPath.self) {
            let showBgPath = ZHMarkPath(width: selPathLineW + selBgPathLineW, color: .red, points: path.markPoints, offset: offset)
            let showPath = ZHMarkPath(width: selPathLineW, color: path.lineColor, points: path.markPoints, offset: offset)
            
            showBgPaths.append(showBgPath)
            showPaths.append(showPath)
        }else if path.isKind(of: ZHCirclePath.self) {
            let showBgPath = ZHCirclePath(width: selPathLineW + selBgPathLineW, color: .red, points: path.markPoints, offset: offset)
            let showPath = ZHCirclePath(width: selPathLineW, color: path.lineColor, points: path.markPoints, offset: offset)
            
            showBgPaths.append(showBgPath)
            showPaths.append(showPath)
        }else if path.isKind(of: ZHLinePath.self) {
            let showBgPath = ZHLinePath(width: selPathLineW + selBgPathLineW, color: .red, points: path.markPoints, offset: offset)
            let showPath = ZHLinePath(width: selPathLineW, color: path.lineColor, points: path.markPoints, offset: offset)
            
            showBgPaths.append(showBgPath)
            showPaths.append(showPath)
        }
        
        
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
            showBgPath.lineColor.set()
            showBgPath.stroke()
            
            showPath.lineColor.set()
            showPath.stroke()
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
