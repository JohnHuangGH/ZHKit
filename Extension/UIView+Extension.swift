//
//  UIView+Extension.swift
//  shineline
//
//  Created by QuanHuan on 2021/4/1.
//

import UIKit

// MARK: - Gesture
extension UIView{
    /// 添加点击手势
    func zh_tapGestureAdd(target: Any?, action: Selector){
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: target, action: action)
        self.addGestureRecognizer(tap)
    }
    /// 添加长按手势
    func zh_longPressGestureAdd(target: Any?, action: Selector){
        self.isUserInteractionEnabled = true
        let lp = UILongPressGestureRecognizer(target: target, action: action)
        self.addGestureRecognizer(lp)
    }
    /// 添加拖拽手势
    func zh_panGestureAdd(target: Any?, action: Selector){
        self.isUserInteractionEnabled = true
        let pan = UIPanGestureRecognizer(target: target, action: action)
        self.addGestureRecognizer(pan)
    }
    /// 添加上滑手势
    func zh_upSwipeGestureAdd(target: Any?, action: Selector){
        self.isUserInteractionEnabled = true
        let swipe = UISwipeGestureRecognizer(target: target, action: action)
        swipe.direction = .up
        self.addGestureRecognizer(swipe)
    }
    /// 添加下滑手势
    func zh_downSwipeGestureAdd(target: Any?, action: Selector){
        self.isUserInteractionEnabled = true
        let swipe = UISwipeGestureRecognizer(target: target, action: action)
        swipe.direction = .down
        self.addGestureRecognizer(swipe)
    }
    /// 添加左滑手势
    func zh_leftSwipeGestureAdd(target: Any?, action: Selector){
        self.isUserInteractionEnabled = true
        let swipe = UISwipeGestureRecognizer(target: target, action: action)
        swipe.direction = .left
        self.addGestureRecognizer(swipe)
    }
    /// 添加右滑手势
    func zh_rightSwipeGestureAdd(target: Any?, action: Selector){
        self.isUserInteractionEnabled = true
        let swipe = UISwipeGestureRecognizer(target: target, action: action)
        swipe.direction = .right
        self.addGestureRecognizer(swipe)
    }
}


