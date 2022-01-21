//
//  ZHDrawView.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/12.
//

import UIKit

enum ZHDrawBoardOption {
    case pen
    case text
    case line
    case circle
    case rect
    case arrow
    case singleSelect
    case multiSelect
}

class ZHDrawView: UIView {
    
    var markStart: (()->Void)?
    
    var option: ZHDrawBoardOption = .pen {
        didSet{
            if oldValue == .singleSelect, option != .singleSelect {
                clearSelectedPath()
                setNeedsDisplay()
            }
        }
    }
    
//    var curScale: CGFloat = 1
    var lineWidth: CGFloat = 4
    var lineColor: UIColor = .black
    
    var isZooming: Bool = false {
        didSet{
            if isZooming, drawPaths.count > 0, let lastPath = drawPaths.last, !lastPath.isValid {
                drawPaths.removeLast()
                setNeedsDisplay()
            }
        }
    }
    
    private var drawPaths: [ZHBasePath] = []{
        didSet{
            showPaths = drawPaths
            if oldValue.count == 0, drawPaths.count > 0 {
                markStart?()
            }
        }
    }
    private var showPaths: [ZHBasePath] = []
    
    private var selectedView: ZHDrawSelectedView?{
        didSet{
            if selectedView == nil, let selView = oldValue {
                selView.selectedPaths.forEach{$0.isSelectedPath = false}
            }
        }
    }
    
    @discardableResult func previous() -> Bool {
        if showPaths.count <= 0 {
            return false
        }
        clearSelectedPath()
        if let lastPath = showPaths.last, let preMovePath = lastPath.preMovePath {
            preMovePath.moved = false
        }
        showPaths.removeLast()
        setNeedsDisplay()
        return showPaths.count > 0
    }
    
    @discardableResult func next() -> Bool {
        if showPaths.count == drawPaths.count {
            return false
        }
        let nextPath = drawPaths[showPaths.count]
        if let preMovePath = nextPath.preMovePath {
            preMovePath.moved = true
        }
        showPaths.append(nextPath)
        setNeedsDisplay()
        return showPaths.count < drawPaths.count
    }
    
    func clear() {
        option = .pen
        drawPaths.removeAll()
        clearSelectedPath()
        setNeedsDisplay()
    }
}

// MARK: touches
extension ZHDrawView {
    override func draw(_ rect: CGRect) {
        showPaths.forEach {
            if option == .singleSelect {
                if !$0.isSelectedPath && !$0.moved {//未选中的才绘制，选中的在框选View中绘制
                    $0.draw()
                }
            }else{
                if !$0.moved {//未移动的才绘制
                    $0.draw()
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isZooming { return }
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        switch option {
        case .pen, .circle, .rect, .arrow, .line:
            if drawPaths.count != showPaths.count {
                drawPaths = showPaths
            }
            var path: ZHBasePath
            switch option {
            case .pen:
                path = ZHMarkPath(width: lineWidth, color: lineColor, point: touchPoint)
            case .circle:
                path = ZHCirclePath(width: lineWidth, color: lineColor, point: touchPoint)
            case .rect:
                path = ZHRectPath(width: lineWidth, color: lineColor, point: touchPoint)
            case .arrow:
                path = ZHArrowPath(width: lineWidth, color: lineColor, point: touchPoint)
            case .line:
                path = ZHLinePath(width: lineWidth, color: lineColor, point: touchPoint)
            default:
                path = ZHBasePath(width: lineWidth, color: lineColor, point: touchPoint)
            }
            drawPaths.append(path)
        case .singleSelect:
            clearSelectedPath()
            setNeedsDisplay()
            //0.倒序遍历，后绘制的优先被选中
            //1.是否落在涂鸦路径上
            for (i, path) in showPaths.reversed().enumerated() {
                if !path.moved && path.contains(touchPoint) {
                    //3.刷新
                    refreshSelectedPath(path: path, insetIndx: showPaths.count - i - 1)
                    return
                }
            }
            //2.是否落在涂鸦框内
            for (i, path) in showPaths.reversed().enumerated() {
                let pathRect = path.cgPath.boundingBox
                if !path.moved && pathRect.contains(touchPoint) {
                    //3.刷新
                    refreshSelectedPath(path: path, insetIndx: showPaths.count - i - 1)
                    return
                }
            }
        default:
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isZooming { return }
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        switch option {
        case .pen, .circle, .rect, .arrow, .line:
            guard let path = drawPaths.last else { return }
            path.draw(to: touchPoint)
            setNeedsDisplay()
        default:
            break
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isZooming { return }
        guard let path = drawPaths.last else { return }
        switch option {
        case .pen, .circle, .rect, .arrow, .line:
            path.isValid = true//如果是缩放，会走began和moved，不走ended
        default:
            break
        }
    }
    
    private func clearSelectedPath(){
        if selectedView == nil { return }
        selectedView?.selectedPaths.forEach{$0.isSelectedPath = false}
        selectedView?.removeFromSuperview()
        selectedView = nil
        
//        setNeedsDisplay()
    }
    
    private func refreshSelectedPath(path: ZHBasePath, insetIndx: Int){
        path.isSelectedPath = true
        let selView = ZHDrawSelectedView(path: path)
        selView.movedHandle = {[weak self] in
            for (i, showPath) in $0.showPaths.enumerated() {
                let selPath = $0.selectedPaths[i]
                selPath.isSelectedPath = false
                selPath.moved = true
                let movedPath = showPath.offset(to: selView.movedRect.origin)
                movedPath.isSelectedPath = true
                movedPath.preMovePath = selPath
                $0.selectedPaths[i] = movedPath
                self?.drawPaths.append(movedPath)
            }
        }
        self.selectedView = selView
        addSubview(selView)
        
        setNeedsDisplay()
    }
}
