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
    /// 第一笔绘制
    var firstMark: (()->Void)?
    
    var markBegan: (()->Void)?
    var markEnded: (()->Void)?
    
    var option: ZHDrawBoardOption = .pen {
        didSet{
            if oldValue == .singleSelect, option != .singleSelect {
                clearSelected()
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
        clearSelected()
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
        clearSelected()
        setNeedsDisplay()
    }
}

// MARK: Touches
extension ZHDrawView {
    override func draw(_ rect: CGRect) {
        showPaths.forEach {
            if $0.moved { return }//未移动的才绘制
            if (option == .singleSelect || option == .multiSelect) && $0.isSelectedPath { return }//未选中的才绘制，选中的在框选View中绘制
            $0.draw()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isZooming { return }
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        switch option {
        case .pen, .circle, .rect, .arrow, .line:
            syncDrawPath()
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
        case .text:
            syncDrawPath()
            let path = ZHTextPath(width: lineWidth, color: lineColor, point: touchPoint)
            
            showTextAlert {[weak self] text in
                path.text = text
                path.draw(to: touchPoint)
                path.isValid = true
                self?.drawPaths.append(path)
                self?.setNeedsDisplay()
                if (self?.drawPaths.count ?? 0) == 1 {
                    self?.firstMark?()
                }
            }
        case .singleSelect:
            clearSelected()
            setNeedsDisplay()
            //0.倒序遍历，后绘制的优先被选中
            //1.是否落在涂鸦路径上
            for path in showPaths.reversed() {
                if !path.moved && path.contains(touchPoint) {
                    //3.刷新
                    refreshSelected(paths: [path])
                    return
                }
            }
            //2.是否落在涂鸦框内
            for path in showPaths.reversed() {
                let pathRect = path.cgPath.boundingBox
                if !path.moved && pathRect.contains(touchPoint) {
                    //3.刷新
                    refreshSelected(paths: [path])
                    return
                }
            }
        case .multiSelect:
            let path = ZHMarkPath(width: 4, color: .red, point: touchPoint)
            drawPaths.append(path)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isZooming { return }
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        switch option {
        case .pen, .circle, .rect, .arrow, .line, .multiSelect:
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
            if drawPaths.count == 1 {
                firstMark?()
            }
        case .multiSelect:
            drawPaths.removeLast()
            clearSelected()
            setNeedsDisplay()
            
            path.close()
            var selPaths: [ZHBasePath] = []
            for showPath in showPaths {
                if showPath.moved { continue }
                var inside: ObjCBool = ObjCBool(false)
                if let arr = showPath.findIntersections(withClosedPath: path, andBeginsInside: &inside), (arr.count > 0 || inside.boolValue) {
                    selPaths.append(showPath)
                }
            }
            if selPaths.count > 0 {
                refreshSelected(paths: selPaths)
            }
        default:
            break
        }
    }
}

// MARK: Private
extension ZHDrawView {
    /// 清空选中
    private func clearSelected(){
        if selectedView == nil { return }
        selectedView?.selectedPaths.forEach{$0.isSelectedPath = false}
        selectedView?.removeFromSuperview()
        selectedView = nil
    }
    
    /// 刷新选中
    private func refreshSelected(paths: [ZHBasePath]){
        let selView = ZHDrawSelectedView(paths: paths) {[weak self] movedPaths in
            self?.syncDrawPath()
            self?.drawPaths += movedPaths
        }
        selectedView = selView
        addSubview(selView)
        
        setNeedsDisplay()
    }
    
    /// 同步显示paths到绘制paths
    private func syncDrawPath(){
        if drawPaths.count != showPaths.count {
            drawPaths = showPaths
        }
    }
    
    /// 文本输入弹窗
    private func showTextAlert(confirmHandle: ((_ text: String)->Void)?){
        guard let curVC = zh_CurrentVC() else { return }
        let alertVC = UIAlertController(title: "添加文字标绘", message: nil, preferredStyle: .alert)
        alertVC.addTextField { tf in
            tf.placeholder = "请输入文字"
        }
        
        let actL = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        let actR = UIAlertAction(title: "确认", style: .default) { act in
            if let tf = alertVC.textFields?.first, let text = tf.text {
                confirmHandle?(text)
            }
        }
        alertVC.addAction(actL)
        alertVC.addAction(actR)
        curVC.present(alertVC, animated: true, completion: nil)
    }
}
