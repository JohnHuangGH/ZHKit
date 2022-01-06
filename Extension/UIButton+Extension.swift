//
//  UIButton+Extension.swift
//  shineline
//
//  Created by QuanHuan on 2021/4/1.
//

import UIKit

extension UIButton {
    func zh_Btn(img: String, state: UIControl.State){
        setImage(UIImage(named: img), for: state)
    }
    
    func zh_Btn(bgImg: String, state: UIControl.State){
        setBackgroundImage(UIImage(named: bgImg), for: state)
    }
    
    func zh_Btn(font size: CGFloat, _ weight: UIFont.Weight = .regular){
        titleLabel?.font = .systemFont(ofSize: size, weight: weight)
    }
}
    
// MARK: - ImgLayout
extension UIButton {
    enum ZHBtnLayout {
        case imgTop
        case imgBottom
        case imgRight
        case imgLeft
    }
    
    /// btn图文布局
    /// - Parameters:
    ///   - layout: 图文相对位置
    ///   - space: 图文间隔
    ///   - maxWidth: btn最大宽度
    ///   - insets: 内边距
    ///   PS：tableviewCell使用自动行高 且 btn的title或image随数据变动时，在layoutSubviews中使用此方法，以免提前触发行高计算，产生约束冲突
    func zh_Btn(layout: ZHBtnLayout, space: CGFloat = 0, maxWidth: CGFloat = 0, insets: UIEdgeInsets = .zero) {
        
        guard let lab = self.titleLabel, let imgv = self.imageView else { return }
        
        imgv.sizeToFit()
        lab.sizeToFit()
        self.sizeToFit()
        
        let imgW = imgv.frame.size.width
        let imgH = imgv.frame.size.height

        var labW = lab.frame.size.width
        if maxWidth > 0 && imgW + space < maxWidth {
            labW = maxWidth - imgW - space
        }
        let labH = CGFloat(lround(Double(lab.frame.size.height)))//取整后浮点型
        
        var imgInsets = UIEdgeInsets.zero
        var labInsets = UIEdgeInsets.zero
        var contentInsets = insets
        
        switch layout {
        case .imgTop:
            imgInsets = UIEdgeInsets(top: -0.5 * (labH + space),
                                       left: 0.5 * labW,
                                       bottom: 0.5 * (labH + space),
                                       right: -0.5 * labW)

            labInsets = UIEdgeInsets(top: 0.5 * (imgH + space),
                                       left: -0.5 * imgW,
                                       bottom: -0.5 * (imgH + space),
                                       right: 0.5 * imgW)

            contentInsets = UIEdgeInsets(top: contentInsets.top + 0.5 * (min(labH, imgH) + space),
                                         left: contentInsets.left - 0.5 * min(imgW, labW),
                                         bottom: contentInsets.bottom + 0.5 * (min(labH, imgH) + space),
                                         right: contentInsets.right - 0.5 * min(imgW, labW))
            
        case .imgBottom:
            imgInsets = UIEdgeInsets(top: 0.5 * (labH + space),
                                       left: 0.5 * labW,
                                       bottom: -0.5 * (labH + space),
                                       right: -0.5 * labW)

            labInsets = UIEdgeInsets(top: -0.5 * (imgH + space),
                                       left: -0.5 * imgW,
                                       bottom: 0.5 * (imgH + space),
                                       right: 0.5 * imgW)

            contentInsets = UIEdgeInsets(top: contentInsets.top + 0.5 * (min(labH, imgH) + space),
                                         left: contentInsets.left - 0.5 * min(imgW, labW),
                                         bottom: contentInsets.bottom + 0.5 * (min(labH, imgH) + space),
                                         right: contentInsets.right - 0.5 * min(imgW, labW))
            
        case .imgRight:
            imgInsets = UIEdgeInsets(top: 0,
                                       left: labW + 0.5 * space,
                                       bottom: 0,
                                       right: -(labW + 0.5 * space))
            
            labInsets = UIEdgeInsets(top: 0,
                                       left: -(imgW + 0.5 * space),
                                       bottom: 0,
                                       right: imgW + 0.5 * space)
            
            contentInsets = UIEdgeInsets(top: contentInsets.top,
                                         left: contentInsets.left + 0.5 * space,
                                         bottom: contentInsets.bottom,
                                         right: contentInsets.right + 0.5 * space)
        default:
            imgInsets = UIEdgeInsets(top: 0,
                                       left: -(0.5 * space),
                                       bottom: 0,
                                       right: 0.5 * space)
            
            labInsets = UIEdgeInsets(top: 0,
                                       left: 0.5 * space,
                                       bottom: 0,
                                       right: -(0.5 * space))
            
            contentInsets = UIEdgeInsets(top: contentInsets.top,
                                         left: contentInsets.left + 0.5 * space,
                                         bottom: contentInsets.bottom,
                                         right: contentInsets.right + 0.5 * space)
        }
        
        self.imageEdgeInsets = imgInsets;
        self.titleEdgeInsets = labInsets;
        self.contentEdgeInsets = contentInsets
    }
}
