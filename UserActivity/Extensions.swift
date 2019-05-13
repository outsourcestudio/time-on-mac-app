//
//  Extensions.swift
//  UserActivity
//
//  Created by RoboApps on 3/5/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Foundation
import Cocoa


enum SwitcherType: Int {
    case year = 0
    case month
    case week
}

struct Period {
    let startDate:Date!
    let endDate:Date!
    init(start:Date, end:Date) {
        self.startDate = start
        self.endDate = end
    }
    static func todayPeriod()->Period{
        var calendar = Calendar.current
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        let date = Date()
        let start = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        return Period(start: start, end: end)
    }
    
    static func periodFromDate(date:Date)->Period{
        var calendar = Calendar.current
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
//        let date = Date()
        let start = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        return Period(start: start, end: end)
    }
    
    static func periodLastDays(days:Int, from:Date)->Period{
        var calendar = Calendar.current
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        let date = calendar.date(byAdding: .day, value: -days, to: from)!
        let start = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        return Period(start: start, end: end)
    }
    
    static func weekPeriods(fromDate:Date, byAdding:Int = 0)->[Period]{
        var periodsArray = [Period]()
        
        var calendar = Calendar.current
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        
        var date = fromDate.endOfWeek
        if byAdding != 0 {
            date = calendar.date(byAdding: .day, value: -byAdding*7, to: date)!
        }
        for i in 1...7 {
            let period = Period.periodLastDays(days: i, from: date)
            periodsArray.append(period)
        }
        return periodsArray
    }
    
    static func monthPeriods(fromDate:Date, byAdding:Int = 0)->[Period]{
        var periodsArray = [Period]()
        var calendar = Calendar.current
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        var date = fromDate.endOfMonth()
        var days = calendar.component(.day, from: date)
        
        if byAdding != 0 {
            date = calendar.date(byAdding: .day, value: -(days + (byAdding-1)*date.getDaysInMonth()), to: fromDate)!.endOfMonth()
            days = date.getDaysInMonth()
        }
        
        for i in 0..<days {
            let period = Period.periodLastDays(days: i, from: date)
            periodsArray.append(period)
        }
        return periodsArray
    }
    
    static func yearPeriods(fromDate:Date, byAdding:Int = 0)->[Period]{
        var periodsArray = [Period]()
        
        var calendar = Calendar.current
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        
        var date = fromDate.endOfYear()
        var months = calendar.component(.month, from: date)
        if byAdding != 0 {
            let days = calendar.component(.day, from: date)
//            date = calendar.date(byAdding: .day, value: -days + 1, to: fromDate.endOfYear())!
            date = calendar.date(byAdding: .month, value: -(months + (byAdding-1)*12), to: date.endOfYear())!
            months = 12//calendar.component(.month, from: date)
        }
        
        for i in 0..<months {
            let date = calendar.date(byAdding: .month, value: -i, to: date)!
            let fDaydate = date.startOfMonth()
            let lDayDate = date.endOfMonth()
            let start = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: fDaydate)!
            let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: lDayDate)!
            let period = Period(start: start, end: end)
            periodsArray.append(period)
        }
        return periodsArray
    }
    
    static func ifTodayInPeriod(period:Period) -> Bool{
        var calendar = Calendar.current
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        
        let nowDate = Date()
        
        return nowDate >= period.startDate && nowDate <= period.endDate
    }

}

extension TimeInterval {
    func intervalAsList() -> (Int,Int,Int) {
        let time = NSInteger(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return (hours,minutes,seconds)
    }
}

extension NSColor {

    static func hex(_ hexString:String) -> NSColor{
        var hex = hexString
        
        if hex.hasPrefix("#") {
            hex = String(hex[hex.index(after: hex.startIndex)...])
        }
        
        guard let hexVal = Int(hex, radix: 16) else {
            return NSColor.black
        }
        
        return NSColor.init(red:   CGFloat( (hexVal & 0xFF0000) >> 16 ) / 255.0,
                            green: CGFloat( (hexVal & 0x00FF00) >> 8 ) / 255.0,
                            blue:  CGFloat( (hexVal & 0x0000FF) >> 0 ) / 255.0, alpha: CGFloat(1.0))

    }
    
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> NSColor {
        return NSColor.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> NSColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return NSColor(red: min(red + percentage/100, 1.0),
                       green: min(green + percentage/100, 1.0),
                       blue: min(blue + percentage/100, 1.0),
                       alpha: alpha)
    }

}


extension Date {
    func monthAsString() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMMM\ndd")
        return df.string(from: self)
    }
    
    func toString(format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    var year: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
    }
    
    func startOfMonth() -> Date {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: self)))!
    }
    
    func startOfYear() -> Date {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        return calendar.date(from: calendar.dateComponents([.year], from: calendar.startOfDay(for: self)))!
    }
    
    func endOfYear() -> Date {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        return calendar.date(byAdding: DateComponents(month: 12, day: -1), to: self.startOfYear())!
    }
    
    func endOfMonth() -> Date {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        return calendar.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    var endOfWeek: Date {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        return calendar.date(byAdding: .day, value: 7, to: sunday)!
    }
    
    func getDaysInMonth() -> Int{
        
        var calendar = Calendar.current
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        
        let dateComponents = DateComponents(year: calendar.component(.year, from: self), month: calendar.component(.month, from: self))
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        
        return numDays
    }
    
    func oldThan(days:Int) -> Bool {
        
        let curentTimeInterval = self.timeIntervalSince1970
        let nowTimeInterval = Date().timeIntervalSince1970

        let b = nowTimeInterval - curentTimeInterval > Double(days*24*60*60) ? true : false
        return b
    }
    
    func equalForStringDate(dateString:String) -> Bool {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        
        return df.string(from: self) == dateString
    }
    
}

protocol NibLoadable {
    static var nibName: String? { get }
    static func createFromNib(in bundle: Bundle) -> Self?
}

extension NibLoadable where Self: NSView {
    
    static var nibName: String? {
        return String(describing: Self.self)
    }
    
    static func createFromNib(in bundle: Bundle = Bundle.main) -> Self? {
        guard let nibName = nibName else { return nil }
        var topLevelArray: NSArray? = nil
        bundle.loadNibNamed(NSNib.Name(nibName), owner: self, topLevelObjects: &topLevelArray)
        guard let results = topLevelArray else { return nil }
        let views = Array<Any>(results).filter { $0 is Self }
        return views.last as? Self
    }
}


extension String {
    
    func date_from_string() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-ddHH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        return dateFormatter.date(from:self)
    }
    
    func toSecond(format:String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let calendar = Calendar.current
        if let d = dateFormatter.date(from: self) {
            var components = calendar.dateComponents([.hour,.minute,.second], from: d)
            let res:Int = components.hour! * 3600 + components.minute! * 60 + components.second!
            return res
        }
        return 0
    }
    
    func indexOf(target: String) -> Int? {
        let range = (self as NSString).range(of: target)
        guard Range.init(range) != nil else {
            return nil
        }
        return range.location
    }
    
    func substring(with nsrange: NSRange) -> String? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return String(self[range])
    }
    
    func localized(withComment comment: String? = nil) -> String {
        return NSLocalizedString(self, comment: comment ?? self)
    }
    
}
