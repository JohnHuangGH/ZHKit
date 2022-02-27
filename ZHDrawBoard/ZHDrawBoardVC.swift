//
//  ZHDrawBoardVC.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/2/11.
//

import UIKit

class ZHDrawBoardVC: UIViewController {
    
    var bgImage: UIImage?
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var scrollContainer: UIView!
    @IBOutlet private weak var bgImgv: UIImageView!
    @IBOutlet private weak var markView: ZHDrawView!
    
    @IBOutlet private weak var optionBar: ZHOptionBar!
    
    /// 图片与画布缩放比
    private var imgScale: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupAction()
    }

    func setupUI(){
        scrollView.maximumZoomScale = 10
        drawAction(option: .pen)
        
//        let screenRect = UIScreen.main.bounds
//        let img = bgImage ?? UIImage.zh_PureColorImage(color: .white, size: screenRect.size)
//
//        let safeInsets = UIApplication.shared.windows[0].safeAreaInsets
//        let drawBoardW = screenRect.width - (safeInsets.left + safeInsets.right)
//        print(img.size)
//        if (img.size.width/img.size.height)/(drawBoardW/screenRect.height) > 1 {//横向
//            let h = img.size.height / img.size.width * drawBoardW
//            let y = (screenRect.height - h)/2.0
//            markView.markRect = CGRect(x: 0, y: y, width: drawBoardW, height: h)
//        }else{//纵向
//            let w = img.size.width / img.size.height * screenRect.height
//            let x = (drawBoardW - w)/2.0
//            markView.markRect = CGRect(x: x, y: 0, width: w, height: screenRect.height)
//        }
        let screenRect = UIScreen.main.bounds
        let img = bgImage ?? UIImage.zh_PureColorImage(color: .white, size: screenRect.size)
        let imgH = img.size.height
        let imgW = img.size.width
        
        let safeInsets = UIApplication.shared.windows[0].safeAreaInsets
        let drawBoardW = screenRect.width - (safeInsets.left + safeInsets.right)
        let drawBoardH = screenRect.height
        if (imgW/imgH)/(drawBoardW/drawBoardH) > 1 {//横向
            let h = imgH / imgW * drawBoardW
            let y = (drawBoardH - h)/2.0
            markView.markRect = CGRect(x: 0, y: y, width: drawBoardW, height: h)
            imgScale = imgW / drawBoardW
        }else{//纵向
            let w = imgW / imgH * drawBoardH
            let x = (drawBoardW - w)/2.0
            markView.markRect = CGRect(x: x, y: 0, width: w, height: drawBoardH)
            imgScale = imgH / drawBoardH
        }
        print("--------screenSize:\(screenRect.size)")
        print("--------imgSize:\(img.size)")
        print("--------imgScale:\(imgScale)")
        bgImgv.image = img
    }
    
    func setupAction(){
        optionBar.penAct = {[weak self] sender in
            self?.drawAction(option: .pen)
        }
        optionBar.lineColorAct = {[weak self] sender in
            self?.markView.lineColor = sender.backgroundColor ?? .black
        }
        optionBar.lineWidthAct = {[weak self] sender in
            self?.markView.lineWidth = sender.isSelected ? 8 : 4
        }
        optionBar.textAct = {[weak self] sender in
            self?.drawAction(option: .text)
        }
        optionBar.circleAct = {[weak self] sender in
            self?.drawAction(option: .circle)
        }
        optionBar.rectAct = {[weak self] sender in
            self?.drawAction(option: .rect)
        }
        optionBar.arrowAct = {[weak self] sender in
            self?.drawAction(option: .arrow)
        }
        optionBar.lineAct = {[weak self] sender in
            self?.drawAction(option: .line)
        }
        
        optionBar.singleSelAct = {[weak self] sender in
            self?.seleteAction(option: .singleSelect)
        }
        optionBar.multiSelAct = {[weak self] sender in
            self?.seleteAction(option: .multiSelect)
        }
        
        optionBar.previousAct = {[weak self] handle in
            handle(self?.markView.previous() ?? false)
        }
        optionBar.nextAct = {[weak self] handle in
            handle(self?.markView.next() ?? false)
        }
        optionBar.clearAct = {[weak self] sender in
            self?.markView.clear()
            self?.drawAction(option: .pen)
        }
        optionBar.exitAct = {[weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
        markView.firstMark = {[weak self] in
            self?.optionBar.singleSelBtn.isEnabled = true
            self?.optionBar.multiSelBtn.isEnabled = true
            self?.optionBar.previousBtn.isEnabled = true
            self?.optionBar.clearBtn.isEnabled = true
        }
    }
    
    func drawAction(option: ZHDrawBoardOption){
        markView.option = option
        scrollView.isScrollEnabled = false
    }
    
    func seleteAction(option: ZHDrawBoardOption){
        markView.option = option
        scrollView.isScrollEnabled = true
    }
}

extension ZHDrawBoardVC: UIScrollViewDelegate {
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
