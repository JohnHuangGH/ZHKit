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

struct JHFloatingType: OptionSet {
    let rawValue: Int
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    static var none     : JHFloatingType {JHFloatingType(rawValue: 0)}
    static var top      : JHFloatingType {JHFloatingType(rawValue: 1<<0)}
    static var right    : JHFloatingType {JHFloatingType(rawValue: 1<<1)}
    static var down     : JHFloatingType {JHFloatingType(rawValue: 1<<2)}
    static var left     : JHFloatingType {JHFloatingType(rawValue: 1<<3)}
    static var all      : JHFloatingType {JHFloatingType(rawValue: top.rawValue|right.rawValue|down.rawValue|left.rawValue)}
}

class JHFloatingItem: UIWindow {
    
    private static var floatingItem: JHFloatingItem?

    private var contentView: UIView = UIView()
    private var rootVC: UIViewController = UIViewController()
    private var floatintType: JHFloatingType = .none
    
    private var lastOrientation: UIDeviceOrientation = .portrait
    private lazy var lastInsets: UIEdgeInsets = kSafeInsets
    
    init(contentView contentV: UIView, rootVC rootVc: UIViewController, type: JHFloatingType){
        //kScreenW - contentV.bounds.width
        let scH = UIDevice.current.orientation.isLandscape ? kScreenW : kScreenH
        super.init(frame: CGRect(origin: CGPoint(x: 0 + kSafeInsets.left, y: (scH - contentV.bounds.height)/2), size: contentV.bounds.size))
        backgroundColor = .clear
        windowLevel = .alert - 1
        contentView = contentV
        rootVC = rootVc
        floatintType = type
        
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
    
    static func show(item contentV: UIView, rootVC rootVc: UIViewController, type: JHFloatingType = .none){
        let item = JHFloatingItem.init(contentView: contentV, rootVC: rootVc, type: type)
        floatingItem = item
        item.isHidden = false
//        lastOrientation = UIDevice.current.orientation
        item.notificationOrientationChanged()
    }
    
    static func close(){
        floatingItem?.isHidden = true
        floatingItem = nil
    }
    
    deinit {
        print("deinit")
    }
    
    @objc private func panAction(_ recognizer: UIPanGestureRecognizer){
        guard let recognizerV = recognizer.view else { return }
        
        let isLandscape = lastOrientation.isLandscape
        let halfItemW = (isLandscape ? contentView.bounds.height : contentView.bounds.width)/2
        let halfItemH = (isLandscape ? contentView.bounds.width : contentView.bounds.height)/2
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
        
        let minX = halfItemW + inset.left
        let maxX = screenW - halfItemW - inset.right
        let minY = halfItemH + inset.top
        let maxY = screenH - halfItemH - inset.bottom
        
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
        
        let oldFrame = frame
//        print("oldFrame:\(oldFrame)")
        let orientation = UIDevice.current.orientation // 不用isPortrait判断是否竖屏，UIDeviceOrientation包含水平方向faceUp，faceDown，!isLandscape就为Portrait
        let inset = kSafeInsets
//        print("inset:\(inset)")
        let itemSize = contentView.bounds.size
        let itemW = itemSize.width
        let itemH = itemSize.height
        
        var angle: CGFloat = 0
        switch orientation {
        case .landscapeLeft:
            angle = .pi * 0.5
        case .landscapeRight:
            angle = .pi * -0.5
        default:
            break
        }
//        print("orientation:\(orientation.rawValue)")
        transform = CGAffineTransform(rotationAngle: angle)
        frame.size = orientation.isLandscape ? CGSize(width: itemH, height: itemW) : itemSize
        
        
        let whChanged: Bool = orientation.isLandscape ? !lastOrientation.isLandscape : lastOrientation.isLandscape//宽高是否对调
        let oldH = whChanged ? kScreenW : kScreenH
        let oldW = whChanged ? kScreenH : kScreenW
        
        let oldContentH = oldH - lastInsets.top - lastInsets.bottom - itemH
        let newContentH = kScreenH - inset.top - inset.bottom - itemH
        
        let itemMinX = itemW/2 + inset.left
        let itemMaxX = kScreenW - inset.right - itemW/2
        
        switch lastOrientation {
        case .landscapeLeft:
            let newX = oldFrame.minY == lastInsets.left ? itemMinX : itemMaxX
            let offsetY = oldH - oldFrame.midX - lastInsets.top - itemH/2
            let newY = offsetY / oldContentH * newContentH + itemH/2 + inset.top
            switch orientation {
            case .portrait:
                center = CGPoint(x: newX, y: newY)
            case .landscapeRight:
                center = CGPoint(x: newY, y: kScreenW - newX)
            default:
                break
            }
        case .landscapeRight:
            let newX = oldFrame.maxY == oldW - lastInsets.left ? itemMinX : itemMaxX
            let offsetY = oldFrame.midX - lastInsets.top - itemH/2
            let newY = offsetY / oldContentH * newContentH + itemH/2 + inset.top
            switch orientation {
            case .portrait:
                center = CGPoint(x: newX, y: newY)
            case .landscapeLeft:
                center = CGPoint(x: kScreenH - newY, y: newX)
            default:
                break
            }
        default:
            let newX = oldFrame.minX == lastInsets.left ? itemMinX : itemMaxX
            let offsetY = oldFrame.midY - lastInsets.top - itemH/2
            let newY = offsetY / oldContentH * newContentH + itemH/2 + inset.top
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
