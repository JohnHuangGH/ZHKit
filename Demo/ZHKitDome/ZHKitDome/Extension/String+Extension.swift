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
    func zh_substring(_ count: Int, _ containsLastEmoji: Bool = false) -> String {
        if count < 1 { return "" }
        if self.count < count { return self }
        
        let nsstr = NSString(string: self)
        let range = nsstr.rangeOfComposedCharacterSequence(at: count)
        let idx = containsLastEmoji ? range.location + range.length : range.location
        return nsstr.substring(to: idx)
    }
}
