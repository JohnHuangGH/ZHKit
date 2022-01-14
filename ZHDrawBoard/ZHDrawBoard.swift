//
//  ZHDrawBoard.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/12.
//

import UIKit

class ZHDrawBoard: UIView {

    private var container: ZHDrawBoardContainer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadContainerFormNib()
    }
    
    private func loadContainerFormNib(){
        container = (Bundle.main.loadNibNamed("ZHDrawBoard", owner: nil, options: nil)?.first as!ZHDrawBoardContainer)
        container.frame = self.frame
        addSubview(container)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

// MARK: - ZHDrawBoardContainer
class ZHDrawBoardContainer: UIView {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var scrollContainer: UIView!
    @IBOutlet weak var bgImgv: UIImageView!
    @IBOutlet weak var markView: ZHDrawBoardMarkView!
    
    @IBOutlet weak var optionBar: ZHDrawBoardOptionBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        markView.markEnded = {[weak self] in
            self?.optionBar.previousBtn.isEnabled = true
            self?.optionBar.nextBtn.isEnabled = false
            self?.optionBar.clearBtn.isEnabled = true
            self?.optionBar.selBtn.isEnabled = true
        }
    }
    
    func setupUI(){
        scrollView.backgroundColor = .black
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.maximumZoomScale = 10
        scrollView.delegate = self
    }
    
    @IBAction func penBtnClick(sender: UIButton){
        sender.isSelected = !sender.isSelected
        markView.canMark = sender.isSelected
        scrollView.isScrollEnabled = !sender.isSelected
    }
    
    @IBAction func selBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        markView.selecting = sender.isSelected
        optionBar.penBtn.isEnabled = !sender.isSelected
        markView.canMark = sender.isSelected ? false : optionBar.penBtn.isSelected
        scrollView.isScrollEnabled = sender.isSelected ? true : !optionBar.penBtn.isSelected
    }
    
    @IBAction func colorBtnClick(_ sender: UIButton) {
        let color = UIColor(red:CGFloat(Int.random(in: 0...255))/255.0 , green: CGFloat(Int.random(in: 0...255))/255.0, blue: CGFloat(Int.random(in: 0...255))/255.0, alpha: 1)
        sender.backgroundColor = color
        markView.lineColor = color
    }
    
    @IBAction func lineWidthBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        markView.lineWidth = sender.isSelected ? 8 : 4
    }
    
    @IBAction func previousBtnClick(_ sender: UIButton) {
        sender.isEnabled = markView.previous()
        optionBar.nextBtn.isEnabled = true
    }
    
    @IBAction func nextBtnClick(_ sender: UIButton) {
        sender.isEnabled = markView.next()
        optionBar.previousBtn.isEnabled = true
    }
    
    @IBAction func clearBtnClick(_ sender: UIButton) {
        markView.clear()
        optionBar.previousBtn.isEnabled = false
        optionBar.nextBtn.isEnabled = false
        optionBar.clearBtn.isEnabled = false
        optionBar.selBtn.isEnabled = false
    }
}

// MARK: UIScrollViewDelegate
extension ZHDrawBoardContainer: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollContainer
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        markView.isZooming = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        markView.curScale = scale
        markView.isZooming = false
    }
}

// MARK: - ZHDrawBoardMarkView
class ZHDrawBoardMarkView: UIView {
    
    var markEnded: (()->Void)?
    
    var canMark: Bool = false
    var selecting: Bool = false{
        didSet{
            if !selecting {
                clearSelectedPath()
                setNeedsDisplay()
            }
        }
    }
    var curScale: CGFloat = 1
    var lineWidth: CGFloat = 4
    var lineColor: UIColor = .black
//    private(set) var showMarkCount: Int = 0
    
    var isZooming: Bool = false {
        didSet{
            if isZooming, drawPaths.count > 0, let lastPath = drawPaths.last, !lastPath.isValid {
                drawPaths.removeLast()
                setNeedsDisplay()
            }
        }
    }
    
    private var drawPaths: [ZHMarkPath] = []{
        didSet{
            showPaths = drawPaths
        }
    }
    private var showPaths: [ZHMarkPath] = []
    
    private var selectedPath: ZHMarkPath?
    
    @discardableResult func previous() -> Bool {
        if showPaths.count <= 0 {
            return false
        }
        showPaths.removeLast()
        setNeedsDisplay()
        return showPaths.count > 0
    }
    
    @discardableResult func next() -> Bool {
        if showPaths.count == drawPaths.count {
            return false
        }
        showPaths.append(drawPaths[showPaths.count])
        setNeedsDisplay()
        return showPaths.count < drawPaths.count
    }
    
    func clear() {
        drawPaths.removeAll()
        setNeedsDisplay()
    }
}

// MARK: touches
extension ZHDrawBoardMarkView {
    override func draw(_ rect: CGRect) {
//        if let selPath = selectedPath, selecting {
//            selPath.lineColor.set()
//            selPath.stroke()
//        }
        showPaths.forEach {
            if !($0.isSelectedPath && !selecting) {
                $0.lineColor.set()
                $0.stroke()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isZooming { return }
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        if canMark {
            if drawPaths.count != showPaths.count {
                drawPaths = showPaths
            }
            let path = ZHMarkPath(width: lineWidth, color: lineColor, point: touchPoint)
            drawPaths.append(path)
        }else if selecting {
            clearSelectedPath()
            //0.倒序遍历，后绘制的优先被选中
            //1.是否落在涂鸦路径上
            for (i, path) in showPaths.reversed().enumerated() {
                for p in path.markPoints {
                    let width: CGFloat = path.lineWidth * curScale
                    let rect = CGRect(x: p.x-width/2, y: p.y-width, width: width, height: width)
                    if rect.contains(touchPoint) {
                        //3.刷新
                        refreshSelectedPath(path: path, insetIndx: showPaths.count - i - 1)
                        return
                    }
                }
            }
            //2.是否落在涂鸦范围内
            for (i, path) in showPaths.reversed().enumerated() {
                let pathRect = path.clickRect()
                if pathRect.contains(touchPoint) {
                    //3.刷新
                    refreshSelectedPath(path: path, insetIndx: showPaths.count - i - 1)
                    return
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isZooming { return }
        if canMark {
            guard let touch = touches.first, let path = drawPaths.last else { return }
            let p = touch.location(in: self)
            path.addLine(to: p)
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {//如果是缩放，会走began和moved，不走ended
        if isZooming { return }
        if canMark {
            guard let path = drawPaths.last else { return }
            path.isValid = true
//            let view = UIView(frame: path.getPathRect())
//            let layer = CAShapeLayer()
//            layer.path = path.cgPath
//            view.layer.addSublayer(layer)
//            addSubview(view)
//            showPaths.removeLast()
//            setNeedsDisplay()
            markEnded?()
        }
    }
    
    private func refreshSelectedPath(path: ZHMarkPath, insetIndx: Int){
        if let selPath = path.copy() as? ZHMarkPath {
            selectedPath = selPath
            selectedPath?.lineColor = .red
            selectedPath?.lineWidth = path.lineWidth * 2
            selectedPath?.isSelectedPath = true
            showPaths.insert(selPath, at: insetIndx)
            
            let width = path.lineWidth
            let dashRect = CGRect(x: path.clickRect().origin.x-width, y: path.clickRect().origin.y-width, width: path.clickRect().size.width + path.lineWidth*2, height: path.clickRect().size.height + path.lineWidth*2)
            let dashRectLayer = CAShapeLayer.zh_DrawDashRect(frame: dashRect, color: .red)
            layer.addSublayer(dashRectLayer)
            
            setNeedsDisplay()
        }
    }
    
    private func clearSelectedPath(){
        selectedPath = nil
        showPaths.removeAll { $0.isSelectedPath }
        layer.sublayers?.forEach({ layer in
            if layer.isKind(of: CAShapeLayer.self) {
                layer.removeFromSuperlayer()
            }
        })
    }
}

// MARK: - ZHDrawBoardOptionBar
enum ZHDrawBoardOption {
    case none
    case pen
    case select
    case multiSelect
}

@IBDesignable class ZHDrawBoardOptionBar: UIView {
    @IBOutlet weak var penBtn: UIButton!
    @IBOutlet weak var selBtn: UIButton!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    
    var option: ZHDrawBoardOption = .none
    
    @IBInspectable var cornerRadius: CGFloat {
        set(value){ layer.cornerRadius = value }
        get{ return layer.cornerRadius }
    }
}
