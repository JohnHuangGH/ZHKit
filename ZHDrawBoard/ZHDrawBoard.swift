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
        container.frame = UIScreen.main.bounds
        addSubview(container)
    }
}

// MARK: - ZHDrawBoardContainer
class ZHDrawBoardContainer: UIView {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var scrollContainer: UIView!
    @IBOutlet weak var bgImgv: UIImageView!
    @IBOutlet weak var markView: ZHDrawView!
    
    @IBOutlet weak var optionBar: ZHDrawBoardOptionBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        markView.firstMark = {[weak self] in
            self?.optionBar.singleSelBtn.isEnabled = true
            self?.optionBar.multiSelBtn.isEnabled = true
            self?.optionBar.previousBtn.isEnabled = true
            self?.optionBar.clearBtn.isEnabled = true
        }
        guard let img = bgImgv.image else { return }
        print("img:\(img.size)\nscreen:\(UIScreen.main.bounds.size)")
        let screenRect = UIScreen.main.bounds
        
        let safeAreaInsets = UIApplication.shared.windows[0].safeAreaInsets
        let width = screenRect.width - (safeAreaInsets.left + safeAreaInsets.right)
        if (img.size.width/img.size.height)/(width/screenRect.height) > 1 {//横向
            let h = img.size.height / img.size.width * width
            let y = (screenRect.height - h)/2.0
            markView.markRect = CGRect(x: 0, y: y, width: width, height: h)
        }else{//纵向
            let w = img.size.width / img.size.height * screenRect.height
            let x = (width - w)/2.0
            markView.markRect = CGRect(x: x, y: 0, width: w, height: screenRect.height)
        }
        print(markView.markRect)
    }
    
    func setupUI(){
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.maximumZoomScale = 10
        scrollView.delegate = self
        
//        print(bgImgv.image?.size)
//        bgImgv.image?.imageOrientation = .up
        
        optionBar.penAct = {[weak self] sender in
            self?.markView.option = .pen
            self?.scrollView.isScrollEnabled = false
        }
        optionBar.lineColorAct = {[weak self] sender in
            self?.markView.lineColor = sender.backgroundColor ?? .black
        }
        optionBar.lineWidthAct = {[weak self] sender in
            self?.markView.lineWidth = sender.isSelected ? 8 : 4
        }
        optionBar.textAct = {[weak self] sender in
            self?.markView.option = .text
            self?.scrollView.isScrollEnabled = false
        }
        optionBar.circleAct = {[weak self] sender in
            self?.markView.option = .circle
            self?.scrollView.isScrollEnabled = false
        }
        optionBar.rectAct = {[weak self] sender in
            self?.markView.option = .rect
            self?.scrollView.isScrollEnabled = false
        }
        optionBar.arrowAct = {[weak self] sender in
            self?.markView.option = .arrow
            self?.scrollView.isScrollEnabled = false
        }
        optionBar.lineAct = {[weak self] sender in
            self?.markView.option = .line
            self?.scrollView.isScrollEnabled = false
        }
        
        optionBar.singleSelAct = {[weak self] sender in
            self?.markView.option = .singleSelect
            self?.scrollView.isScrollEnabled = true
        }
        optionBar.multiSelAct = {[weak self] sender in
            self?.markView.option = .multiSelect
            self?.scrollView.isScrollEnabled = true
        }
        
        optionBar.previousAct = {[weak self] handle in
            handle(self?.markView.previous() ?? false)
        }
        optionBar.nextAct = {[weak self] handle in
            handle(self?.markView.next() ?? false)
        }
        optionBar.clearAct = {[weak self] sender in
            self?.markView.clear()
        }
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
