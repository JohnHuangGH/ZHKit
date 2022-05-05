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
fileprivate var kSafeInsets: UIEdgeInsets { UIApplication.shared.windows[0].safeAreaInsets }

class JHFloatingHelper: NSObject {
    static let shared = JHFloatingHelper()
    
    var safeInsets: UIEdgeInsets = kSafeInsets
    var floatingItem: JHFloatingItem?
    
    func show(contentV: UIView, rootVC: UIViewController){
        let item = JHFloatingItem.init(contentView: contentV, rootVC: rootVC)
        floatingItem = item
        item.show()
    }
    
    func close(){
        floatingItem = nil
    }
}

class JHFloatingItem: UIWindow {
    
//    private static var item: JHFloatingItem?

    private var contentView: UIView = UIView()
    private var rootVC: UIViewController = UIViewController()
    private var lastOrientation: UIDeviceOrientation = .portrait
    private var lastInsets: UIEdgeInsets = kSafeInsets
    
    init(contentView contentV: UIView, rootVC rootVc: UIViewController){
        //kScreenW - contentV.bounds.width
        super.init(frame: CGRect(origin: CGPoint(x: kScreenW - contentV.bounds.width, y: (kScreenH - contentV.bounds.height)/2), size: contentV.bounds.size))
        backgroundColor = .clear
        windowLevel = .alert - 1
        contentView = contentV
        rootVC = rootVc
        
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
        
        let isLandscape = lastOrientation.isLandscape
        let halfContentW = (isLandscape ? contentView.bounds.height : contentView.bounds.width)/2
        let halfContentH = (isLandscape ? contentView.bounds.width : contentView.bounds.height)/2
        let screenW = isLandscape ? kScreenH : kScreenW
        let screenH = isLandscape ? kScreenW : kScreenH
        
        var point = recognizer.translation(in: recognizerV)
        var inset = kSafeInsets
        
        switch lastOrientation {
        case .landscapeLeft:
            point = CGPoint(x: -point.y, y: point.x)
            inset = UIEdgeInsets(top: inset.left, left: inset.bottom, bottom: inset.right, right: inset.top)
        case .landscapeRight:
            point = CGPoint(x: point.y, y: -point.x)
            inset = UIEdgeInsets(top: inset.right, left: inset.top, bottom: inset.left, right: inset.bottom)
        default:
            break
        }
        
        let minX = halfContentW + inset.left
        let maxX = screenW - halfContentW - inset.right
        let minY = halfContentH + inset.top
        let maxY = screenH - halfContentH - inset.bottom
        
        var movedX = point.x + recognizerV.center.x
        if movedX < minX {
            movedX = minX
        } else if movedX > maxX {
            movedX = maxX
        }
        var movedY = point.y + recognizerV.center.y
        if movedY < minY {
            movedY = minY
        } else if movedY > maxY {
            movedY = maxY
        }
        
        center = CGPoint(x: movedX, y: movedY)
        recognizer.setTranslation(.zero, in: self)
        
        switch recognizer.state {
        case .ended, .cancelled, .failed:
            if isLandscape {
                center.y = center.y < kScreenW/2 ? minY : maxY
            }else{
                center.x = center.x < kScreenW/2 ? minX : maxX
            }
//            print("\(frame)")
        default: break
        }
    }
    
    @objc private func notificationOrientationChanged(){
//        print("screenW:\(kScreenW)")
        let oldFrame = frame
//        print("oldFrame:\(oldFrame)")
        let orientation = UIDevice.current.orientation
        let inset = kSafeInsets
//        print("inset:\(inset)")
        
        var angle: CGFloat = 0
        switch orientation {
        case .landscapeLeft:
//            print("landscapeLeft")
            angle = .pi * 0.5
        case .landscapeRight:
//            print("landscapeRight")
            angle = .pi * -0.5
        default:
//            print("portrait")
            break
        }
        
        transform = CGAffineTransform(rotationAngle: angle)
        
        let newSize = lastOrientation.isLandscape && orientation.isLandscape ? oldFrame.size : CGSize(width: oldFrame.height, height: oldFrame.width)
        frame.size = newSize
        
        let isLandscape = lastOrientation.isLandscape
        let halfContentW = contentView.bounds.width/2
        let halfContentH = contentView.bounds.height/2
//        let screenW = isLandscape ? kScreenH : kScreenW
//        let screenH = isLandscape ? kScreenW : kScreenH
        
        let whChanged: Bool = orientation.isLandscape ? lastOrientation.isPortrait : lastOrientation.isLandscape//宽高是否对调
        let oldH = whChanged ? kScreenW : kScreenH
        let oldW = whChanged ? kScreenH : kScreenW
        
        switch lastOrientation {
        case .landscapeLeft:
            let newX = oldFrame.minY == lastInsets.left ? halfContentW + inset.left : kScreenW - inset.right - halfContentW
            let newY = (oldH - oldFrame.midX) / oldH * kScreenH
            switch orientation {
            case .portrait:
                center = CGPoint(x: newX, y: newY)
            case .landscapeRight:
                center = CGPoint(x: newY, y: kScreenW - newX)
            default:
                break
            }
        case .landscapeRight:
            let newX = oldFrame.maxY == oldW - lastInsets.left ? halfContentW + inset.left : kScreenW - inset.right - halfContentW
            let newY = oldFrame.midX / oldH * kScreenH
            switch orientation {
            case .portrait:
                center = CGPoint(x: newX, y: newY)
            case .landscapeLeft:
                center = CGPoint(x: kScreenH - newY, y: newX)
            default:
                break
            }
        default:
            let newX = oldFrame.minX == lastInsets.left ? halfContentW + inset.left : kScreenW - inset.right - halfContentW
            let newY = oldFrame.midY / oldH * kScreenH
            switch orientation {
            case .landscapeLeft:
                center = CGPoint(x: kScreenH - newY, y: newX)
            case .landscapeRight:
                center = CGPoint(x: newY, y: kScreenW - newX)
            default:
                break
            }
            break
        }

        lastOrientation = orientation
        lastInsets = inset
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
