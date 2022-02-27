//
//  ZHDrawBoardVC.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/2/11.
//

import UIKit

class ZHDrawBoardVC: UIViewController {
    
    var bgImage: UIImage = UIImage.zh_pureColorImage(color: .white, size: UIScreen.main.bounds.size)
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var scrollContainer: UIView!
    @IBOutlet private weak var bgImgv: UIImageView!
    @IBOutlet private weak var drawView: ZHDrawView!
    
    @IBOutlet private weak var optionBar: ZHOptionBar!
    
    /// 图片与画布缩放比
    private var imgScale: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupAction()
    }

    func setupUI(){
        let screenRect = UIScreen.main.bounds
        let imgH = bgImage.size.height * bgImage.scale
        let imgW = bgImage.size.width * bgImage.scale
        
        let safeInsets = UIApplication.shared.windows[0].safeAreaInsets
        let drawBoardW = screenRect.width - (safeInsets.left + safeInsets.right)
        let drawBoardH = screenRect.height
        if (imgW/imgH)/(drawBoardW/drawBoardH) > 1 {//横向
            let h = imgH / imgW * drawBoardW
            let y = (drawBoardH - h)/2.0
            drawView.markRect = CGRect(x: 0, y: y, width: drawBoardW, height: h)
            imgScale = imgW / drawBoardW
        }else{//纵向
            let w = imgW / imgH * drawBoardH
            let x = (drawBoardW - w)/2.0
            drawView.markRect = CGRect(x: x, y: 0, width: w, height: drawBoardH)
            imgScale = imgH / drawBoardH
        }
        
        bgImgv.image = bgImage
        drawAction(option: .pen)
    }
    
    func setupAction(){
        optionBar.penAct = {[weak self] sender in
            self?.drawAction(option: .pen)
        }
        optionBar.lineColorAct = {[weak self] sender in
            self?.drawView.lineColor = sender.backgroundColor ?? .black
        }
        optionBar.lineWidthAct = {[weak self] sender in
            self?.drawView.lineWidth = sender.isSelected ? 8 : 4
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
        
        optionBar.singleSelAct = {[weak self] sender in
            self?.seleteAction(option: .singleSelect)
        }
        optionBar.multiSelAct = {[weak self] sender in
            self?.seleteAction(option: .multiSelect)
        }
        
        optionBar.previousAct = {[weak self] handle in
            handle(self?.drawView.previous() ?? false)
        }
        optionBar.nextAct = {[weak self] handle in
            handle(self?.drawView.next() ?? false)
        }
        optionBar.clearAct = {[weak self] sender in
            self?.drawView.clear()
            self?.drawAction(option: .pen)
        }
        optionBar.exitAct = {[weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
        drawView.firstMark = {[weak self] in
            self?.optionBar.singleSelBtn.isEnabled = true
            self?.optionBar.multiSelBtn.isEnabled = true
            self?.optionBar.previousBtn.isEnabled = true
            self?.optionBar.clearBtn.isEnabled = true
        }
    }
    
    func drawAction(option: ZHDrawBoardOption){
        drawView.option = option
        scrollView.isScrollEnabled = false
    }
    
    func seleteAction(option: ZHDrawBoardOption){
        drawView.option = option
        scrollView.isScrollEnabled = true
    }
}

extension ZHDrawBoardVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollContainer
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        drawView.isZooming = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//        drawView.curScale = scale
        drawView.isZooming = false
    }
}
