//
//  ZHDrawSelectedView.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/17.
//

import UIKit

let kSelBgPathLineW: CGFloat = 4
let kDashLineW: CGFloat = 2

class ZHDrawSelectedView: UIView {
    
    var movedHandle: ((_ movedPaths: [ZHBasePath])->Void)?
    
    var selectedPaths: [ZHBasePath] = []
    var showPaths: [ZHBasePath] = []
    private var showBgPaths: [ZHBasePath] = []
    
    var originalRect: CGRect = .zero
    var movedRect: CGRect = .zero
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(recognizer:)))
        addGestureRecognizer(pan)
        
        let dashRect = CGRect(origin: .zero, size: frame.size)
        let dashRectLayer = CAShapeLayer.zh_DrawDashRect(frame: dashRect, lineWidth: kDashLineW, color: .red)
        layer.addSublayer(dashRectLayer)
        originalRect = frame
    }
    
    convenience init(paths: [ZHBasePath], movedHandle: ((_ movedPaths: [ZHBasePath])->Void)?) {
        var boundingBoxs: [CGRect] = []
        var showPaths: [ZHBasePath] = []
        var showBgPaths: [ZHBasePath] = []
        for path in paths {
            path.isSelectedPath = true
            let pathRect = path.cgPath.boundingBoxOfPath
            let selPathLineW = path.isFill ? 0 : path.lineWidth
            
            let viewX = pathRect.origin.x - (selPathLineW + kSelBgPathLineW + kDashLineW) * 0.5
            let viewY = pathRect.origin.y - (selPathLineW + kSelBgPathLineW + kDashLineW) * 0.5
            let viewW = pathRect.size.width + selPathLineW + kSelBgPathLineW + kDashLineW
            let viewH = pathRect.size.height + selPathLineW + kSelBgPathLineW + kDashLineW
            let boundingBox = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
            boundingBoxs.append(boundingBox)
        }
        
        let viewRect = boundingBoxs.zh_RectsBoundingBox()
        let offset = CGPoint(x: -viewRect.origin.x, y: -viewRect.origin.y)
        
        for path in paths {
            let selPathLineW = path.isFill ? 0 : path.lineWidth
            let showBgPath = path.copyPath()
            showBgPath.offset(to: offset)
            showBgPath.lineWidth = selPathLineW + kSelBgPathLineW
            showBgPath.lineColor = .red
            showBgPaths.append(showBgPath)

            let showPath = path.copyPath()
            showPath.offset(to: offset)
            showPaths.append(showPath)
        }
        
        self.init(frame: viewRect)
        self.selectedPaths = paths
        self.showPaths = showPaths
        self.showBgPaths = showBgPaths
        self.movedHandle = movedHandle
    }
    
    override func draw(_ rect: CGRect) {
        for (idx, showPath) in showPaths.enumerated() {
//            let showBgPath = showBgPaths[idx]
//            showBgPath.isFill ? showBgPath.stroke() : showBgPath.draw()
            showBgPaths[idx].stroke()
            
            showPath.draw()
        }
    }
    
    private var panBeginPoint: CGPoint = .zero
    /// 拖拽事件
    @objc private func panAction(recognizer: UIPanGestureRecognizer){
        if recognizer.state == .began {
            panBeginPoint = recognizer.location(in: self)
        }
        let p = recognizer.location(in: self.superview)
        var rect = self.frame
        rect.origin = CGPoint(x: p.x - panBeginPoint.x, y: p.y - panBeginPoint.y)
        movedRect = rect
        self.frame = rect
        if recognizer.state == .ended {
            for (i, path) in showPaths.enumerated() {
                let selPath = selectedPaths[i]
                selPath.isSelectedPath = false
                selPath.moved = true
                let movedPath = path.copyPath()
                movedPath.offset(to: movedRect.origin)
                movedPath.isSelectedPath = true
                movedPath.preMovePath = selPath
                selectedPaths[i] = movedPath
            }
            movedHandle?(selectedPaths)
        }
    }
}
