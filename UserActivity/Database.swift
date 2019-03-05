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
        var lines: [String] = []
        output.enumerateLines { line, _ in
            lines.append(line)
        }
        for (index, element) in lines.enumerated() {
            print(index, ":", element)
        }
    }
    
    func date_from_string(date_string: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-ddHH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        return dateFormatter.date(from:date_string)!
    }
    
    
}
