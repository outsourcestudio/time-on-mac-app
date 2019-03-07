//
//  Extensions.swift
//  UserActivity
//
//  Created by toxa on 3/5/19.
//  Copyright © 2019 Sergiy Kurash. All rights reserved.
//

import Foundation
import Cocoa

struct Period {
    let startDate:Date!
    let endDate:Date!
    init(start:Date, end:Date) {
        self.startDate = start
        self.endDate = end
    }
    static func todayPeriod()->Period{
        let calendar = Calendar.current
        let date = Date()
        let start = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        return Period(start: start, end: end)
    }
    static func periodLastDays(days:Int)->Period{
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: -days, to: Date())!
        let start = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        return Period(start: start, end: end)
    }
    
//    static func weekPeriod()->Period{
//        let calendar = Calendar.current
//        let date = calendar.date(byAdding: .day, value: -7*24*60*60, to: Date())!
//        let start = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
//        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
//        return Period(start: start, end: end)
//    }
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

extension Date {
    func monthAsString() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMMM\ndd")
        return df.string(from: self)
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
}
