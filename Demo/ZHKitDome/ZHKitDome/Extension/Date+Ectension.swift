//
//  Date+Ectension.swift
//  shineline
//
//  Created by QuanHuan on 2021/4/6.
//

import Foundation

enum ZHDateFormat: String {
    case UTC    = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    
    case Date_Time      = "yyyy-MM-dd HH:mm:ss"
    case Date_Time_MdHm = "MM-dd HH:mm"
    case Date           = "yyyy-MM-dd"
    case Date_yM        = "yyyy-MM"
    case Date_Md        = "MM-dd"
    case Time           = "HH:mm:ss"
    case Time_Hm        = "HH:mm"
    case Time_ms        = "mm:ss"
    
    case Date_Time_CN       = "yyyy年MM月dd日 HH时mm分ss秒"
    case Date_Time_MdHm_CN  = "MM月dd日 HH时mm分"
    case Date_CN            = "yyyy年MM月dd日"
    case Date_yM_CN         = "yyyy年MM月"
    case Date_Md_CN         = "MM月dd日"
    case Time_CN            = "HH时mm分ss秒"
    case Time_Hm_CN         = "HH时mm分"
    case Time_ms_CN         = "mm分ss秒"
}

enum ZHWeekdayStyle: String {
    case zhou   = "EEE"
    case xingqi = "EEEE"
}

// MARK: - Date
extension Date {
    /// 获取DateComponents
    func zh_getDateComponents(_ comps: Set<Calendar.Component> = [.era, .year, .month, .day, .hour, .minute, .second, .weekday, .timeZone]) -> DateComponents {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.dateComponents(comps, from: self)
    }
    
    /// 获取DateFormatter
    static func zh_getFormatter(dateFormat: String, _ timezone: TimeZone! = TimeZone(abbreviation: "GMT+8")) -> DateFormatter{
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.dateFormat = dateFormat
        return formatter
    }
    
    /// 是否同一天
    func zh_isSameDay(_ date: Date) -> Bool {
        let comp1 = zh_getDateComponents([.year, .month, .day])
        let comp2 = date.zh_getDateComponents([.year, .month, .day])
        return (comp1.day == comp2.day) && (comp1.month == comp2.month) && (comp1.year == comp2.year)
    }
    
    /// 是否同一月
    func zh_isSameMonth(_ date: Date) -> Bool {
        let comp1 = zh_getDateComponents([.year, .month, .day])
        let comp2 = date.zh_getDateComponents([.year, .month, .day])
        return (comp1.month == comp2.month) && (comp1.year == comp2.year)
    }
    
    /// 是否同一年
    func zh_isSameYear(_ date: Date) -> Bool {
        let comp1 = zh_getDateComponents([.year, .month, .day])
        let comp2 = date.zh_getDateComponents([.year, .month, .day])
        return comp1.year == comp2.year
    }
    
    /// 是否今天
    func zh_isToday() -> Bool {
        return zh_isSameDay(Date())
    }
    
    /// 是否本月
    func zh_isThisMonth() -> Bool {
        return zh_isSameMonth(Date())
    }
    
    /// 是否今年
    func zh_isThisYear() -> Bool {
        return zh_isSameYear(Date())
    }
    
    /// 获取0时0分0秒Date（default：东8区）
    func zh_zeroDate(_ timezone: TimeZone! = TimeZone(abbreviation: "GMT+8")) -> Date {
//        var zeroComp = self.zh_getDateComponents()
//        zeroComp.hour = 0
//        zeroComp.minute = 0
//        zeroComp.second = 0
//        return Calendar.current.date(from: zeroComp) ?? self
        
        let formatter = Date.zh_getFormatter(dateFormat: ZHDateFormat.Date.rawValue, timezone)
        let dateStr = formatter.string(from: self)
        return formatter.date(from: dateStr) ?? Date()
    }
}

// MARK: - Date -> DateString
extension Date {
    /// 获取格式化Date字符串
    func zh_DateStr(with dateFormat: String, _ timezone: TimeZone! = TimeZone(abbreviation: "GMT+8")) -> String {
        return Date.zh_getFormatter(dateFormat: dateFormat, timezone).string(from: self)
    }
    /// 获取格式化Date字符串
    func zh_DateStr(with format: ZHDateFormat) -> String {
        return zh_DateStr(with: format.rawValue)
    }
    /// 获取获取星期(周)几
    func zh_weekStr(with style: ZHWeekdayStyle) -> String {
        return zh_DateStr(with: style.rawValue)
    }
    /// h：%d
    func zh_12hStr() -> String {
        let hour = self.zh_getDateComponents().hour ?? 0
        return hour > 12 ? "\(hour - 12)" : "\(hour)"
    }
    /// h：%02d
    func zh_12hhStr() -> String {
        let hour = self.zh_getDateComponents().hour ?? 0
        return hour > 12 ? String(format: "%02d", hour - 12) : String(format: "%02d", hour)
    }
    func zh_AmPmStr() -> String {
        let hour = self.zh_getDateComponents().hour ?? 0
        return hour < 12 ? "am" : "pm"
    }
    func zh_AmPmCNStr() -> String {
        let hour = self.zh_getDateComponents().hour ?? 0
        return hour < 12 ? "上午" : "下午"
    }
}

// MARK: - TimeStamp -> DateString
extension Date {
    /// 时间戳获取格式化Date字符串
    static func zh_DateStr(timeStamp: TimeInterval,  dateFormat: String) -> String {
        return Date(timeIntervalSince1970: timeStamp).zh_DateStr(with: dateFormat)
    }
    /// 时间戳获取格式化Date字符串
    static func zh_DateStr(timeStamp: TimeInterval, zhDateFormat: ZHDateFormat) -> String {
        return zh_DateStr(timeStamp: timeStamp, dateFormat: zhDateFormat.rawValue)
    }
    /// 时间戳获取星期(周)几
    static func zh_weekStr(timeStamp: TimeInterval, style: ZHWeekdayStyle) -> String {
        return zh_DateStr(timeStamp: timeStamp, dateFormat: style.rawValue)
    }
}

// MARK: - DateString -> Date
extension Date {
    /// Date字符串格式化为Date
    static func zh_date(with dateStr: String, _ dateFormat: String, _ timezone: TimeZone! = TimeZone(abbreviation: "GMT+8")) -> Date? {
        return Date.zh_getFormatter(dateFormat: ZHDateFormat.Date.rawValue, timezone).date(from: dateStr)
    }
    /// Date字符串格式化为Date
    static func zh_date(with dateStr: String, _ zhFormat: ZHDateFormat) -> Date? {
        return zh_date(with: dateStr, zhFormat.rawValue)
    }
}
