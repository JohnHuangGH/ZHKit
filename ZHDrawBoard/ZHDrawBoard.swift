//
//  ZHDrawBoard.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/12.
//

import UIKit

class ZHDrawBoard: UIView {
    
    var image: UIImage?{
        didSet{
            container.bgImage = image ?? UIImage.zh_PureColorImage(color: .white, size: UIScreen.main.bounds.size)
        }
    }

    private var container: ZHDrawBoardContainer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadContainerFormNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadContainerFormNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func loadContainerFormNib(){
        container = (Bundle.main.loadNibNamed("ZHDrawBoard", owner: nil, options: nil)?.first as! ZHDrawBoardContainer)
        container.frame = UIScreen.main.bounds
        addSubview(container)

        image = nil
    }
}

// MARK: - ZHDrawBoardContainer
class ZHDrawBoardContainer: UIView {
    
    var bgImage: UIImage? {
        didSet{
            guard let img = bgImage else { return }
    //        print("img:\(img.size)\nscreen:\(UIScreen.main.bounds.size)")
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
    //        print(markView.markRect)
            bgImgv.image = img
        }
    }
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var scrollContainer: UIView!
    @IBOutlet private weak var bgImgv: UIImageView!
    @IBOutlet private weak var markView: ZHDrawView!
    
    @IBOutlet private weak var optionBar: ZHDrawBoardOptionBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        markView.firstMark = {[weak self] in
            self?.optionBar.singleSelBtn.isEnabled = true
            self?.optionBar.multiSelBtn.isEnabled = true
            self?.optionBar.previousBtn.isEnabled = true
            self?.optionBar.clearBtn.isEnabled = true
        }
    }
    
    func setupUI(){
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.maximumZoomScale = 10
        scrollView.delegate = self
        drawAction(option: .pen)
        
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
