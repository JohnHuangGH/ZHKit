//
//  UIDevice+Extension.swift
//  ZHKitDemo
//
//  Created by NetInfo on 2021/11/19.
//

import UIKit

extension UIDevice {
    /// 获取设备型号
    static func zh_getDeviceModel() -> String {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let deviceString = withUnsafePointer(to: &systemInfo.machine, { (ptr) -> String? in
            let deviceChars = unsafeBitCast(ptr, to: UnsafePointer<CChar>.self)
            return String.init(cString: deviceChars, encoding: .utf8)
        })
        
        let deviceType = [
            //iPhone(手机)
            "iPhone1,1" : "iPhone",
            "iPhone1,2" : "iPhone3G",
            "iPhone2,1" : "iPhone3GS",
            "iPhone3,1" : "iPhone4",
            "iPhone3,2" : "iPhone4",
            "iPhone3,3" : "iPhone4",
            "iPhone4,1" : "iPhone4S",
            "iPhone5,1" : "iPhone5",
            "iPhone5,2" : "iPhone5",
            "iPhone5,3" : "iPhone5C",
            "iPhone5,4" : "iPhone5C",
            "iPhone6,1" : "iPhone5S",
            "iPhone6,2" : "iPhone5S",
            "iPhone7,2" : "iPhone6",
            "iPhone7,1" : "iPhone6 Plus",
            "iPhone8,1" : "iPhone6s",
            "iPhone8,2" : "iPhone6s Plus",
            "iPhone10,3" : "iPhone X",
            "iPhone10,6" : "iPhone X",
            "iPhone11,2" : "iPhone XS",
            "iPhone11,4" : "iPhone XS MAX",
            "iPhone11,6" : "iPhone XS MAX",
            "iPhone11,8" : "iPhone XR",
            "iPhone12,1" : "iPhone 11",
            "iPhone12,3" : "iPhone 11 Pro",
            "iPhone12,5" : "iPhone 11 Pro Max",
            "iPhone12,8" : "iPhone SE 2",
            "iPhone13,1" : "iPhone 12 mini",
            "iPhone13,2" : "iPhone 12",
            "iPhone13,3" : "iPhone 12 Pro",
            "iPhone13,4" : "iPhone 12 Pro Max",
            "iPhone14,4" : "iPhone 13 mini",
            "iPhone14,5" : "iPhone 13",
            "iPhone14,2" : "iPhone 13 Pro",
            "iPhone14,3" : "iPhone 13 Pro Max",

        ]
        
        
        if let deviceStringKey = deviceString {
            if deviceStringKey.hasPrefix("x86") {
                return "iPhone模拟器，Mac"
            } else {
                if let deviceTypeString = deviceType[deviceStringKey] {
                    return deviceTypeString
                }
            }
        }
        return "iPhone新机型"
    }
    
    static func currentOrientation() -> UIInterfaceOrientation {
        guard let value = current.value(forKey: "orientation") as? NSNumber, let orientation = UIInterfaceOrientation(rawValue: value.intValue) else { return .unknown }
        return orientation
    }
}
