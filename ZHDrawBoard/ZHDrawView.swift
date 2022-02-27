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
    case circle
    case rect
    case arrow
    case singleSelect
    case multiSelect
}

class ZHDrawView: UIView {
    var markRect: CGRect = .zero
    var lineWidth: CGFloat = 4
    var lineColor: UIColor = .black
    var fontSize: CGFloat = 10
    
    var option: ZHDrawBoardOption = .pen {
        didSet{
            if (oldValue == .singleSelect && option != .singleSelect) || (oldValue == .multiSelect && option != .multiSelect) {
                clearSelected()
                setNeedsDisplay()
            }
        }
    }
    
    /// 第一笔绘制
    var firstMark: (()->Void)?
    
    private var drawPaths: [ZHBasePath] = []{
        didSet{
            showPaths = drawPaths
        }
    }
    private var showPaths: [ZHBasePath] = []
    
    private var multiSelPath: ZHBasePath?
    
    private var selectedView: ZHSelectedView?{
        didSet{
            if selectedView == nil, let selView = oldValue {
                selView.selectedPaths.forEach{$0.isSelectedPath = false}
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @discardableResult func previous() -> Bool {
        if showPaths.count <= 0 {
            return false
        }
        clearSelected()
//        if let lastPath = showPaths.last, let preMovePath = lastPath.preMovePath {
//            preMovePath.moved = false
//        }
//        showPaths.removeLast()
        if let lastPath = showPaths.last {
            let modifyTime = lastPath.modifyTime
            if modifyTime > 0 {
                let paths = showPaths.filter{$0.modifyTime == modifyTime}
                paths.forEach{ $0.preMovePath?.moved = false }
                let prevPaths = showPaths.filter{!(paths.contains($0))}
                showPaths = prevPaths
            }else{
                lastPath.preMovePath?.moved = false
                showPaths.removeLast()
            }
        }
        setNeedsDisplay()
        return showPaths.count > 0
    }
    
    @discardableResult func next() -> Bool {
        if showPaths.count == drawPaths.count {
            return false
        }
        clearSelected()
        let nextPath = drawPaths[showPaths.count]
//        if let preMovePath = nextPath.preMovePath {
//            preMovePath.moved = true
//        }
//        showPaths.append(nextPath)
        let modifyTime = nextPath.modifyTime
        if modifyTime > 0 {
            let paths = drawPaths.filter{$0.modifyTime == modifyTime}
            paths.forEach{ $0.preMovePath?.moved = true }
            showPaths += paths
        }else{
            nextPath.preMovePath?.moved = true
            showPaths.append(nextPath)
        }
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
        multiSelPath?.draw()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
//        print(touchPoint)
        if !markRect.contains(touchPoint) { return }
        if let lastPath = drawPaths.last, !lastPath.isFinish {//移除被打断的多选路径
            drawPaths.removeLast()
        }
        switch option {
        case .pen, .circle, .rect, .arrow:
            syncDrawPath()
            let path = createPath(point: touchPoint)
            drawPaths.append(path)
        case .text:
            syncDrawPath()
            let path = ZHTextPath(width: lineWidth, color: lineColor, point: touchPoint)
            
            showTextAlert {[weak self] text in
                path.text = text
                path.draw(to: touchPoint)
                self?.drawPaths.append(path)
                self?.finishDraw(path: path)
                self?.setNeedsDisplay()
            }
        case .singleSelect:
            clearSelected()
            setNeedsDisplay()
            checkSingleSelect(touchPoint: touchPoint)
        case .multiSelect:
            if selectedView?.frame.contains(touchPoint) ?? false { return }// 避免事件还未判定成功前，产生多余path
            multiSelPath = ZHPenPath(width: 4, color: .red, point: touchPoint)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        switch option {
        case .pen, .circle, .rect, .arrow:
            guard let path = drawPaths.last else { return }
            if !markRect.contains(touchPoint) {//超出范围，结束当前绘制
                finishDraw(path: path)
                return
            }
            if path.isFinish {//超出范围后重新回到绘制区域，开启新绘制
                let newPath = createPath(point: touchPoint)
                drawPaths.append(newPath)
                newPath.draw(to: touchPoint)
                setNeedsDisplay()
                return
            }
            path.draw(to: touchPoint)
            setNeedsDisplay()
        case .multiSelect:
            multiSelPath?.draw(to: touchPoint)
            setNeedsDisplay()
        default:
            break
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {//如果是缩放，会走began和moved，不走ended
//        print(#function)
        switch option {
        case .pen, .circle, .rect, .arrow:
            guard let path = drawPaths.last else { return }
            finishDraw(path: path)
        case .multiSelect:
            guard let path = multiSelPath else { return }
            multiSelPath = nil
            clearSelected()
            setNeedsDisplay()
            
            path.close()
            checkMultiSelect(path: path)
        default:
            break
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print(#function)
        switch option {
        case .pen, .circle, .rect, .arrow:
            if let lastPath = drawPaths.last, !lastPath.isValid {
                drawPaths.removeLast()
                setNeedsDisplay()
            }
        case .multiSelect:
            multiSelPath = nil
            setNeedsDisplay()
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
        default:
            path = ZHBasePath(width: lineWidth, color: lineColor, point: point)
        }
        return path
    }
    /// 完成当前绘制路径
    private func finishDraw(path: ZHBasePath){
        if !(path.isKind(of: ZHPenPath.self) || path.isKind(of: ZHTextPath.self)), path.markPoints.count < 2 {
            drawPaths.removeLast()
            return
        }
        path.isValid = true
        path.isFinish = true
        if drawPaths.count == 1 {
            firstMark?()
        }
    }
    
    /// 判定落点是否在绘制路径上或者绘制路径的有效选中区内
    private func checkSingleSelect(touchPoint: CGPoint){
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
    }
    /// 判定圈选路径是否包含绘制路径
    private func checkMultiSelect(path: ZHBasePath){
        if path.markPoints.count == 1 {//作单选判定
            checkSingleSelect(touchPoint: path.markPoints[0])
            return
        }
        
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
    }
    
    /// 清空选中
    private func clearSelected(){
        if selectedView == nil { return }
        selectedView?.selectedPaths.forEach{$0.isSelectedPath = false}
        selectedView?.removeFromSuperview()
        selectedView = nil
    }
    
    /// 刷新选中
    private func refreshSelected(paths: [ZHBasePath]){
        let selView = ZHSelectedView(paths: paths) {[weak self] movedPaths in
            self?.syncDrawPath()
            if movedPaths.count > 0 {
                let time = Date().timeIntervalSince1970
                movedPaths.forEach{ $0.modifyTime = time }
            }
            self?.drawPaths += movedPaths
        } deleteHandle: {[weak self] in
            self?.deleteSeleted()
        }
        selectedView = selView
        addSubview(selView)
        
        setNeedsDisplay()
    }
    /// 删除选中
    private func deleteSeleted(){
        guard let selView = selectedView else { return }
        for path in selView.selectedPaths {
            path.deleted()
        }
        drawPaths.removeAll{$0.isDeleted}
        clearSelected()
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
        guard let curVC = zh_currentVC() else { return }
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
