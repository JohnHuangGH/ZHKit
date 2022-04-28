//
//  JHFloatingItem.swift
//  ZHKitDemo
//
//  Created by JohnHuang on 2022/4/28.
//  Copyright © 2022 https://github.com/JohnHuangGH. All rights reserved.
//

import UIKit
import SnapKit

fileprivate var kScreenW: CGFloat { UIScreen.main.bounds.width }
fileprivate var kScreenH: CGFloat { UIScreen.main.bounds.height }
fileprivate let kSafeInsets = UIApplication.shared.windows[0].safeAreaInsets

class JHFloatingHelper: NSObject {
    static let shared = JHFloatingHelper()
    
    var safeInsets: UIEdgeInsets = kSafeInsets
    var floatingItem: JHFloatingItem?
    
    func show(contentV: UIView){
        let item = JHFloatingItem.init(contentView: contentV)
        floatingItem = item
        item.show()
    }
    
    func close(){
        floatingItem = nil
    }
}

class JHFloatingItem: UIWindow {

    private var contentView: UIView = UIView()
    private var lastOrientation: UIDeviceOrientation = .portrait
    
    init(contentView contentV: UIView){
        super.init(frame: CGRect(origin: CGPoint(x: 0, y: kScreenH/2), size: contentV.bounds.size))
        backgroundColor = .clear
        windowLevel = .alert - 1
        contentView = contentV
        
        addSubview(contentV)
        contentV.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        zh_panGestureAdd(target: self, action: #selector(panAction(_:)))
        NotificationCenter.default.addObserver(self, selector: #selector(notificationOrientationChanged), name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(){
        isHidden = false
        lastOrientation = UIDevice.current.orientation
    }
    
    @objc private func panAction(_ recognizer: UIPanGestureRecognizer){
        guard let recognizerV = recognizer.view else { return }
        let point = recognizer.translation(in: recognizer.view)
        
        let halfContentW = contentView.bounds.width/2
        
        let minX = halfContentW
        let maxX = kScreenW - halfContentW
        let minY = halfContentW + JHFloatingHelper.shared.safeInsets.top
        let maxY = kScreenH - JHFloatingHelper.shared.safeInsets.bottom - halfContentW
        
        var movedX = recognizerV.center.x + point.x
        if movedX < minX {
            movedX = minX
        } else if movedX > maxX {
            movedX = maxX
        }
        var movedY = recognizerV.center.y + point.y
        if movedY < minY {
            movedY = minY
        } else if movedY > maxY {
            movedY = maxY
        }
        center = CGPoint(x: movedX, y: movedY)
        recognizer.setTranslation(.zero, in: self)
        
        switch recognizer.state {
        case .ended, .cancelled, .failed:
            center.x = center.x < kScreenW/2 ? minX : maxX
        default: break
        }
    }
    
    @objc private func notificationOrientationChanged(){
        print("screenW:\(kScreenW)")
        var angle: CGFloat = 0
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portrait:
            print("portrait")
        case .portraitUpsideDown:
            print("portraitUpsideDown")
            angle = .pi
        case .landscapeRight:
            print("landscapeRight")
            angle = .pi * -0.5
        case .landscapeLeft:
            print("landscapeLeft")
            angle = .pi * 0.5
        default:
            print("unknown")
        }
        transform = CGAffineTransform(rotationAngle: angle)
        lastOrientation = orientation
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
