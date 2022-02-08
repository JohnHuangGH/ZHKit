//
//  ZHDrawSelectedView.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/17.
//

import UIKit

fileprivate let kSelBgPathLineW: CGFloat = 4
fileprivate let kDashLineW: CGFloat = 2

class ZHDrawSelectedView: UIView {
    
    var selectedPaths: [ZHBasePath] = []
    
    private var movedHandle: ((_ movedPaths: [ZHBasePath])->Void)?
    private var deleteHandle: (()->Void)?
    
    private var showPaths: [ZHBasePath] = []
    private var showBgPaths: [ZHBasePath] = []
    
    private var originalRect: CGRect = .zero
    private var movedRect: CGRect = .zero
    
    private lazy var deleteBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(deleteBtnClick(sender:)), for: .touchUpInside)
        return btn
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        backgroundColor = .clear
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(recognizer:)))
        addGestureRecognizer(pan)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(recognizer:)))
        pinch.delegate = self
        addGestureRecognizer(pinch)
        //在pinch判定为失败时再执行pan
        pan.shouldRequireFailure(of: pinch)
        
        let dashRect = CGRect(origin: .zero, size: frame.size)
        let dashRectLayer = CAShapeLayer.zh_DrawDashRect(frame: dashRect, lineWidth: kDashLineW, color: .red)
        layer.addSublayer(dashRectLayer)
        originalRect = frame
        
        deleteBtn.frame = CGRect(x: frame.midX-frame.minX-10, y: frame.height+10, width: 20, height: 20)
        addSubview(deleteBtn)
    }
    
    convenience init(paths: [ZHBasePath], movedHandle: ((_ movedPaths: [ZHBasePath])->Void)?, deleteHandle: (()->Void)?) {
        var boundingBoxs: [CGRect] = []
        var showPaths: [ZHBasePath] = []
        var showBgPaths: [ZHBasePath] = []
        for path in paths {
            path.isSelectedPath = true
            let pathRect = path.pathBounding()
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
            showBgPath.applyByCenter(transform: CGAffineTransform(translationX: offset.x, y: offset.y))
            showBgPath.lineWidth = selPathLineW + kSelBgPathLineW
            showBgPath.lineColor = .red
            showBgPaths.append(showBgPath)

            let showPath = path.copyPath()
            showPath.applyByCenter(transform: CGAffineTransform(translationX: offset.x, y: offset.y))
            showPaths.append(showPath)
        }
        
        self.init(frame: viewRect)
        self.selectedPaths = paths
        self.showPaths = showPaths
        self.showBgPaths = showBgPaths
        self.movedHandle = movedHandle
        self.deleteHandle = deleteHandle
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
                movedPath.applyByCenter(transform: CGAffineTransform(translationX: movedRect.minX, y: movedRect.minY))
                movedPath.isSelectedPath = true
                movedPath.isValid = true
                movedPath.isFinish = true
                movedPath.preMovePath = selPath
                selectedPaths[i] = movedPath
                originalRect = movedRect
            }
            movedHandle?(selectedPaths)
        }
    }
    
    private var pinchBeginScale: CGFloat = 1
    @objc private func pinchAction(recognizer: UIPinchGestureRecognizer){
        let scale = recognizer.scale
        self.transform = CGAffineTransform(scaleX: pinchBeginScale * scale, y: pinchBeginScale * scale)
        if recognizer.state == .ended {
            pinchBeginScale = pinchBeginScale * scale
            var movedShowPaths: [ZHBasePath] = []
            for (i, path) in showPaths.enumerated() {
                let selPath = selectedPaths[i]
                selPath.isSelectedPath = false
                selPath.moved = true
                let movedShowPath = path.copyPath()
                movedShowPath.scale = movedShowPath.scale * scale
                movedShowPath.lineWidth = movedShowPath.lineWidth * scale
                movedShowPath.applyByCenter(transform: CGAffineTransform(scaleX: scale, y: scale))
                movedShowPaths.append(movedShowPath)
                let movedPath = path.copyPath()
                movedPath.applyByCenter(transform: CGAffineTransform(translationX: originalRect.minX, y: originalRect.minY))
                movedPath.scale = movedPath.scale * scale
                movedPath.lineWidth = movedPath.lineWidth * scale
                movedPath.applyByCenter(transform: CGAffineTransform(scaleX: scale, y: scale))
                movedPath.isSelectedPath = true
                movedPath.isValid = true
                movedPath.isFinish = true
                movedPath.preMovePath = selPath
                selectedPaths[i] = movedPath
            }
            showPaths = movedShowPaths
            movedHandle?(selectedPaths)
        }
    }
    
    @objc private func deleteBtnClick(sender: UIButton){
        deleteHandle?()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if deleteBtn.frame.contains(point) {
            return deleteBtn
        }
        return super.hitTest(point, with: event)
    }
}

extension ZHDrawSelectedView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) {
            return selectedPaths.count == 1
        }
        return true
    }
}
