//
//  Database.swift
//  UserActivity
//
//  Created by Sergiy Kurash on 3/2/19.
//  Copyright © 2019 Sergiy Kurash. All rights reserved.
//

import Foundation

class Database {
    
    var model = [Session]()
    var currentSession:Session!
    var events = [Event]()
    var loading:Bool = false
    
    enum ReasonType{
        
        case user, display, screen
    }
    
    enum Switcher{
        
        case on, off
    }
    
    init () {
        // uncomment this line if your class has been inherited from any other class
        //super.init()
    }
    
    init(output: String) {
        var lines: [String] = []
        output.enumerateLines { line, _ in
            lines.append(line)
        }
//        print(lines)   // "[Line 1, Line 2, Line 3]"
        model = generateSessions(lines: lines)
        print (model.count)
    }
    
    func generateEvents(output: String, events: [Event], reasonType: ReasonType) -> [Event] {
        var lines: [String] = []
        var mutable_events = events
        output.enumerateLines { line, _ in
            lines.append(line)
        }
        for (_, element) in lines.enumerated() {
//            print (element)
            switch reasonType {
            case .display:
                let t_string_array = element.components(separatedBy: " Notification ")
                let time_string = t_string_array[0].replacingOccurrences(of: " ", with: "",
                                                                         options: NSString.CompareOptions.literal, range:nil)
                let date = date_from_string(date_string: time_string)
                let event = Event()
                event.event_time = date // пишем время по гринвичу!!
                event.reason = Event.ReasonType.display
                if element.contains("Display is turned on"){
                    event.switcher = Event.Switcher.on
                    mutable_events.append(event)
                } else if element.contains("Display is turned off"){
                    event.switcher = Event.Switcher.off
                    mutable_events.append(event)
                }
            case .user:
                let regex = try! NSRegularExpression(pattern: "^.*console[ ]+", options: NSRegularExpression.Options.caseInsensitive)
                let range = NSMakeRange(0, element.count)
                let modString = regex.stringByReplacingMatches(in: element, options: [], range: range, withTemplate: "")
                
//                print(modString)

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy EEE MMM d HH:mm"//this your string date format
                dateFormatter.timeZone = TimeZone.current // пишем время по гринвичу!!
                let t_string_array = modString.components(separatedBy: " - ").count < 2 ? modString.components(separatedBy: "   still logged in") : modString.components(separatedBy: " - ")
                var date_string = t_string_array[0]
                let year = Date()
                date_string = year.year + " " + date_string // ПРОВЕРИТЬ НА БУДУЩЕЕ
                var date = dateFormatter.date(from: date_string)
                if date?.compare(Date()) == .orderedDescending && date != nil { // если дата больше текущей отнимаем год
                    date = Calendar.current.date(byAdding: .year, value: -1, to: date!)!
                }
                let event = Event()
                event.reason = Event.ReasonType.user
                event.switcher = Event.Switcher.on
                event.event_time = date
                mutable_events.append(event)
                
                if modString.contains("(") && modString.contains(")"), let date = date {
                    let endSecond = getSecondFromTime(string: modString)
                    let calendar = Calendar.current
                    let endDate = calendar.date(byAdding: .second, value: endSecond, to: date)!
                    let event = Event()
                    event.reason = Event.ReasonType.user
                    event.switcher = Event.Switcher.off
                    event.event_time = endDate
                    mutable_events.append(event)
                }
                
                // end session time logic
                // 1 - check for latest "still logged in"
                // calculate date from parentesis
//                work      console                   Sat Nov  3 19:54 - 20:09  (00:15)
//                work      console                   Sat Nov  3 19:06 - crash  (00:47)
//                work      console                   Sun Dec  9 16:17 - 00:39  (08:22)
//                work      console                   Fri Dec  7 11:07 - 16:14 (2+05:07)
//                work      console                   Thu Jan  3 10:41 - 00:34  (13:53)
//                work      console                   Thu Jan  3 10:40 - shutdown  (13:53)
//                work      console                   Wed Mar  6 07:59   still logged in
//                work      console                   Tue Mar  5 23:37 - 00:38  (01:00)
            case .screen:
                let on = element.contains("about to call lockScreen") ? true : false
                let t_string_array = element.components(separatedBy: " 0x")
                let time_string = t_string_array[0]//.replacingOccurrences(of: " ", with: "",
//                                                                         options: NSString.CompareOptions.literal, range:nil)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                //"2019-03-05 09:41:44.982274+0200"
                let date = dateFormatter.date(from: time_string)
                
                let event = Event()
                event.event_time = date // пишем время по гринвичу!!
                event.reason = .screen
                event.switcher = on ? Event.Switcher.on : Event.Switcher.off
                mutable_events.append(event)
                
            }
        }
        return mutable_events
    }
    
    private func getSecondFromTime(string:String) -> Int{
        if let pos_f = string.indexOf(target: "("), let pos_e = string.indexOf(target: ")") {
            if let res = string.substring(with: NSRange(location: pos_f+1, length: pos_e - pos_f-1)) {
                let a = res.components(separatedBy: "+")
                var daySecond = 0
                 if a.count > 1, let dayStr = a.first, let days = Int(dayStr) {
                    let timeStr = a[1]
                    daySecond = days * 24 * 60 * 60 + timeStr.toSecond(format: "HH:mm")
                }else if a.count > 0 {
                    let timeStr = a[0]
                    daySecond = timeStr.toSecond(format: "HH:mm")
                }
                return daySecond
            }
        }
        return 0
    }
    
    func generateSessions(lines: [String]) -> [Session]{
        var sessions: [Session] = []
        var t_session = Session()
        for (_, element) in lines.enumerated() {
//            print(index, ":", element)
            let t_string_array = element.components(separatedBy: " Notification ")
            let time_string = t_string_array[0].replacingOccurrences(of: " ", with: "",
                                                                     options: NSString.CompareOptions.literal, range:nil)
            let date = date_from_string(date_string: time_string)
            if element.contains("Display is turned on"){
                t_session = Session()
                t_session.start_time = date
            } else if element.contains("Display is turned off"){
                t_session.end_time = date
                if (t_session.start_time != nil) {
                    t_session.period = t_session.end_time?.timeIntervalSince(t_session.start_time!)
                }
                if t_session.start_time != nil && t_session.end_time != nil{
                   sessions.append(t_session)
                }
            }
            let calendar = Calendar.current
            if t_session.start_time != nil && t_session.end_time == nil /*&& calendar.isDateInToday(t_session.start_time!) */{
                currentSession = t_session
            }
        }
        return sessions
    }
    
    
    func getSessions(period:Period? = nil) ->[Session]{
        if period == nil {
            return self.model
        }
        let a = model.filter { (session) -> Bool in // добавить Same
            return session.start_time!.compare(period!.startDate) == .orderedDescending && session.end_time!.compare(period!.endDate) == .orderedAscending
        }
        
        return a
    }
    
    func maxPerid(period:Period? = nil) -> TimeInterval {
        var localSessions = model
        if period != nil {
            localSessions = model.filter { (session) -> Bool in // добавить Same
                return session.start_time!.compare(period!.startDate) == .orderedDescending && session.end_time!.compare(period!.endDate) == .orderedAscending
            }
        }
        let a = localSessions.sorted { (s1, s2) -> Bool in
            let p1 = s1.period ?? 0
            let p2 = s2.period ?? 0
            return p1 < p2
            }.last
        return a?.period ?? 0
    }
    
    func addReason(output: String) {
//        var lines: [String] = []
//        output.enumerateLines { line, _ in
//            lines.append(line)
//        }
//        for (index, element) in lines.enumerated() {
//            print(index, ":", element)
//        }
    }
    
    func date_from_string(date_string: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-ddHH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        return dateFormatter.date(from:date_string)!
    }
    
    
}

extension Date {
    var year: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
    }
}
