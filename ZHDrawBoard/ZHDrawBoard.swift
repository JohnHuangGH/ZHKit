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
    
    @IBAction func colorBtnClick(_ sender: UIButton) {
        let color = UIColor(red:CGFloat(Int.random(in: 0...255))/255.0 , green: CGFloat(Int.random(in: 0...255))/255.0, blue: CGFloat(Int.random(in: 0...255))/255.0, alpha: 1)
        sender.backgroundColor = color
        markView.lineColor = color
    }
    
    @IBAction func lineWidthBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        markView.lineWidth = sender.isSelected ? 4 : 2
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
//        markView.curScale = scale
        markView.isZooming = false
    }
}

// MARK: - ZHDrawBoardMarkView
class ZHDrawBoardMarkView: UIView {
    
    var markEnded: (()->Void)?
    
    var canMark: Bool = false
//    var curScale: CGFloat = 1
    var lineWidth: CGFloat = 2
    var lineColor: UIColor = .black
    private(set) var showMarkCount: Int = 0
    
    var isZooming: Bool = false {
        didSet{
            if isZooming && drawPaths.count > 0 {
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
    
    override func draw(_ rect: CGRect) {
        showPaths.forEach {
            $0.lineColor.set()
            $0.stroke()
        }
    }
}

// MARK: touches
extension ZHDrawBoardMarkView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if canMark && !isZooming {
            guard let touch = touches.first else { return }
            if drawPaths.count != showPaths.count {
                drawPaths = showPaths
            }
            let p = touch.location(in: self)
            let path = ZHMarkPath()
            path.lineWidth = lineWidth
            path.lineColor = lineColor
            path.lineCapStyle = .round
            path.move(to: p)
            drawPaths.append(path)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if canMark && !isZooming {
            guard let touch = touches.first, let path = drawPaths.last else { return }
            let p = touch.location(in: self)
            path.addLine(to: p)
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {//如果是缩放，会走began和moved，不走ended
        if canMark && !isZooming {
            guard let path = drawPaths.last else { return }
            markEnded?()
        }
    }
}

// MARK: - ZHDrawBoardOptionBar
@IBDesignable
class ZHDrawBoardOptionBar: UIView {
    @IBOutlet weak var penBtn: UIButton!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
}
