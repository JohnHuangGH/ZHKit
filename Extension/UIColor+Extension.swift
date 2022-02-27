//
//  UIColor+Extension.swift
//  ZHKitDemo
//
//  Created by NetInfo on 2022/1/6.
//

import UIKit

func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
    return UIColor(red: r, green: g, blue: g, alpha: a)
}

extension String {
    func uicolor() -> UIColor {
        return UIColor.zh_hex(self)
    }
    
    func cgcolor() -> CGColor {
        return uicolor().cgColor
    }
}

extension UIColor {
    class func zh_hex(_ hexStr: String) -> UIColor {
        guard !hexStr.isEmpty && hexStr.hasPrefix("#") && hexStr.count == 7 else { return .white }
        
        let hexString = hexStr.replacingOccurrences(of: "#", with: "")
        var hex: UInt64 = 0
        Scanner.init(string: hexString).scanHexInt64(&hex)
        
        return UIColor(red: CGFloat((hex & 0xff0000) >> 16) / 255.0,
                       green: CGFloat((hex & 0x00ff00) >> 8) / 255.0,
                       blue: CGFloat((hex & 0x0000ff)) / 255.0,
                       alpha: 1)
    }
    
    class func zh_ahex(_ hexStr: String) -> UIColor {
        guard !hexStr.isEmpty && hexStr.hasPrefix("#") && hexStr.count == 9 else { return .white }
        
        let hexString = hexStr.replacingOccurrences(of: "#", with: "")
        var hex: UInt64 = 0
        Scanner.init(string: hexString).scanHexInt64(&hex)
        
        return UIColor(red: CGFloat((hex & 0x00ff0000) >> 16) / 255.0,
                       green: CGFloat((hex & 0x0000ff00) >> 8) / 255.0,
                       blue: CGFloat((hex & 0x000000ff)) / 255.0,
                       alpha: CGFloat((hex & 0xff000000) >> 24) / 255.0)
    }
    
    class func zh_hexa(_ hexStr: String) -> UIColor {
        guard !hexStr.isEmpty && hexStr.hasPrefix("#") && hexStr.count == 9 else { return .white }
        
        let hexString = hexStr.replacingOccurrences(of: "#", with: "")
        var hex: UInt64 = 0
        Scanner.init(string: hexString).scanHexInt64(&hex)
        
        return UIColor(red: CGFloat((hex & 0xff000000) >> 24) / 255.0,
                       green: CGFloat((hex & 0x00ff0000) >> 16) / 255.0,
                       blue: CGFloat((hex & 0x0000ff00) >> 8) / 255.0,
                       alpha: CGFloat((hex & 0x000000ff)) / 255.0)
    }
    
    class func zh_random() -> UIColor {
        return rgba(CGFloat(Int.random(in: 0...255)) / 255.0,
                    CGFloat(Int.random(in: 0...255)) / 255.0,
                    CGFloat(Int.random(in: 0...255)) / 255.0,
                    1)
    }
}
