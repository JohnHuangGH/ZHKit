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

class ZHDrawBoardContainer: UIView {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bgImgv: UIImageView!
    private var curScale: CGFloat = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    func setupUI(){
        scrollView.backgroundColor = .black
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.maximumZoomScale = 10
        scrollView.delegate = self
    }
}

extension ZHDrawBoardContainer: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return bgImgv
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        curScale = scale
    }
}
