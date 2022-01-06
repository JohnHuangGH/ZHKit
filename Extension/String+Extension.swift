//
//  String+Extension.swift
//  shineline
//
//  Created by QuanHuan on 2021/6/8.
//

import UIKit

extension String {
    /// String裁切（处理裁切含emoji字符串时末位可能乱码，去除末位emoji）
    /// - Parameters:
    ///   - count: 裁切位数
    ///   - containsLast: 若末位为emoji，是否包含末位emoji
    /// - Returns: String
    func zh_subString(count: Int, containsLastEmoji: Bool = false) -> String {
        if count < 1 { return "" }
        if self.count < count { return self }
        
        let nsstr = NSString(string: self)
        let range = nsstr.rangeOfComposedCharacterSequence(at: count)
        let idx = containsLastEmoji ? range.location + range.length : range.location
        return nsstr.substring(to: idx)
    }
    
    /// 是否为正确URL
    func zh_isURL() -> Bool {
        let regex = "[a-zA-z]+://[^\\s]*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    /// 以OC的形式获取Range<String.Index> (swift中Range是个区间,不同于OC的结构体)
    /// - Parameters:
    ///   - loc: 起始下标
    ///   - len: 长度
    /// - Returns: Range
    func zh_makeRange(_ loc: Int, _ len: Int) -> Range<String.Index> {
        return index(startIndex, offsetBy: loc) ..< index(startIndex, offsetBy: loc+len)
    }
    
    /// 隐私手机号
    /// - Returns: 123****6789
    func zh_phonePrivacy() -> String{
        return count < 11 ? self : replacingCharacters(in: zh_makeRange(3, 4), with: "****")
    }
    
    /// 获取划线价格
    /// - Returns: 带划线的富文本
    func zh_getUnderlineString() -> NSAttributedString{
        let attrs = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
        return NSAttributedString(string: self, attributes: attrs)
    }
    
    /// 截取到任意位置
    func zh_subString(to: Int) -> String {
        let index: String.Index = self.index(startIndex, offsetBy: to)
        return String(self[..<index])
    }
    /// 从任意位置开始截取
    func zh_subString(from: Int) -> String {
        let index: String.Index = self.index(startIndex, offsetBy: from)
        return String(self[index ..< endIndex])
    }
    /// 从任意位置开始截取到任意位置
    func zh_subString(from: Int, to: Int) -> String {
        let beginIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[beginIndex...endIndex])
    }
//    //使用下标截取到任意位置
//    subscript(to: Int) -> String {
//        let index = self.index(self.startIndex, offsetBy: to)
//        return String(self[..<index])
//    }
//    //使用下标从任意位置开始截取到任意位置
//    subscript(from: Int, to: Int) -> String {
//        let beginIndex = self.index(self.startIndex, offsetBy: from)
//        let endIndex = self.index(self.startIndex, offsetBy: to)
//        return String(self[beginIndex...endIndex])
//    }
}
