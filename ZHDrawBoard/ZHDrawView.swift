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
    var markRect: CGRect = .zero
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
    
    lazy var deleteBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = .zero
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(deleteBtnClick(sender:)), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(deleteBtn)
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
    
    @objc private func deleteBtnClick(sender: UIButton){
        guard let selView = selectedView else { return }
        for path in selView.selectedPaths {
            path.deleted()
            drawPaths.removeAll{$0.isDeleted}
        }
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
        if !markRect.contains(touchPoint) { return }
        switch option {
        case .pen, .circle, .rect, .arrow, .line:
            syncDrawPath()
            let path = createPath(point: touchPoint)
            drawPaths.append(path)
        case .text:
            syncDrawPath()
            let path = ZHTextPath(width: lineWidth, color: lineColor, point: touchPoint)
            
            showTextAlert {[weak self] text in
                path.text = text
                path.draw(to: touchPoint)
                self?.finishDraw(path: path)
                self?.drawPaths.append(path)
                self?.setNeedsDisplay()
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
            let path = ZHPenPath(width: 4, color: .red, point: touchPoint)
            drawPaths.append(path)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isZooming { return }
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        guard let path = drawPaths.last else { return }
        if !markRect.contains(touchPoint) {
            finishDraw(path: path)
            return
        }
        if path.isFinish {
            let newPath = createPath(point: touchPoint)
            drawPaths.append(newPath)
        }
        guard let path = drawPaths.last else { return }
        switch option {
        case .pen, .circle, .rect, .arrow, .line, .multiSelect:
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
            //如果是缩放，会走began和moved，不走ended
            finishDraw(path: path)
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
    ///开启新绘制路径
    private func createPath(point: CGPoint) -> ZHBasePath {
        var path: ZHBasePath
        switch option {
        case .pen:
            path = ZHPenPath(width: lineWidth, color: lineColor, point: point)
        case .circle:
            path = ZHCirclePath(width: lineWidth, color: lineColor, point: point)
        case .rect:
            path = ZHRectPath(width: lineWidth, color: lineColor, point: point)
        case .arrow:
            path = ZHArrowPath(width: lineWidth, color: lineColor, point: point)
        case .line:
            path = ZHLinePath(width: lineWidth, color: lineColor, point: point)
        default:
            path = ZHBasePath(width: lineWidth, color: lineColor, point: point)
        }
        return path
    }
    /// 完成当前绘制路径
    private func finishDraw(path: ZHBasePath){
        path.isValid = true
        path.isFinish = true
        if drawPaths.count == 1 {
            firstMark?()
        }
    }
    /// 清空选中
    private func clearSelected(){
        if selectedView == nil { return }
        selectedView?.selectedPaths.forEach{$0.isSelectedPath = false}
        selectedView?.removeFromSuperview()
        selectedView = nil
        deleteBtn.isHidden = true
    }
    
    /// 刷新选中
    private func refreshSelected(paths: [ZHBasePath]){
        let selView = ZHDrawSelectedView(paths: paths) {[weak self] movedPaths in
            self?.syncDrawPath()
            self?.drawPaths += movedPaths
        }
        selectedView = selView
        addSubview(selView)
        deleteBtn.frame = CGRect(x: selView.center.x-10, y: selView.frame.maxY + 10, width: 20, height: 20)
        deleteBtn.isHidden = false
        
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
