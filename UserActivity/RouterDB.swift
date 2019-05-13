//
//  RouterDB.swift
//  UserActivity
//
//  Created by RoboApps on 3/14/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Foundation
import Cocoa
import RealmSwift


class RouterDB {
    
    private let realm = try? Realm()
    private var currentSession:Session? = nil
    
    
    func getEvents() ->[Event]?{
        if let objs = realm?.objects(Event.self).sorted(byKeyPath: "event_time") {
            return Array(objs)
        }
        return nil
    }
    
    func getSessions(period:Period? = nil) ->[Session]{
        
        if let objs = realm?.objects(Event.self).sorted(byKeyPath: "event_time") {
            let sessions = self.generateSessions(events: Array(objs))
            if period == nil {
                return sessions
            }
            
            let a = sessions.filter { (session) -> Bool in // добавить Same
                return session.end_time! >= period!.startDate && session.start_time <= period!.endDate
              }
            for sess in a{
                if sess.end_time! > period!.endDate {
                    sess.end_time = period!.endDate
                    sess.period = sess.end_time?.timeIntervalSince(sess.start_time!)
                }
                if sess.start_time < period!.startDate {
                    sess.start_time = period!.startDate
                    sess.period = sess.end_time?.timeIntervalSince(sess.start_time!)
                }
            }
            return a
        }
        
        return []

        
//        if let objs = realm?.objects(Event.self).sorted(byKeyPath: "event_time") {
//            let sessions = self.generateSessions(events: Array(objs))
//            if period == nil {
//                return sessions
//            }
//            let a = sessions.filter { (session) -> Bool in // добавить Same
//                return session.end_time! >= period!.startDate && session.start_time <= period!.endDate
//                //(session.start_time!.compare(period!.startDate) == .orderedDescending || session.start_time!.compare(period!.startDate) == .orderedSame)  &&
//                    //(session.end_time!.compare(period!.endDate) == .orderedAscending || session.end_time!.compare(period!.endDate) == .orderedSame)
//            }
//            return a
//        }
//
//        return []
    }
    
    func getCurrentSession() ->Session? {
        var curSession:Session?
        if let objs = realm?.objects(Event.self).sorted(byKeyPath: "event_time") {
            let events = Array(objs)
            for (_, element) in events.enumerated() {
                var t_session:Session? = Session()
                if element.switcher == .on {
                    t_session = Session()
                    t_session?.start_time = element.event_time
                    
                } else {
                    if (t_session != nil){
                        t_session!.end_time = element.event_time
                        if (t_session!.start_time != nil) {
                            t_session!.period = t_session!.end_time?.timeIntervalSince(t_session!.start_time!)
                        }
                        if t_session!.start_time != nil && t_session!.end_time != nil{
                            t_session = nil
                        }
                    }
                }
                if t_session?.start_time != nil && t_session?.end_time == nil{
                    curSession = t_session!
                }
            }
        }
        return curSession
    }
    
    func printAllEvents(){
        if let objs = realm?.objects(Event.self).sorted(byKeyPath: "event_time") {
            let events = Array(objs)
            events.forEach { (e) in
                print(e.event_time!, e.reason.rawValue(), e.switcher.rawValue())
            }
        }
    }
    
    private func generateSessions(events: [Event]) -> [Session]{
        var sessions: [Session] = []
        var t_session:Session?
        for (_, element) in events.enumerated() {
            //            print(index, ":", element)
            if element.switcher == .on {
                t_session = Session()
                t_session?.start_time = element.event_time

            } else {
                if (t_session != nil){
                    t_session?.end_time = element.event_time
                    if (t_session?.start_time != nil) {
                        t_session?.period = t_session?.end_time?.timeIntervalSince(t_session!.start_time!)
                    }
                    if t_session?.start_time != nil && t_session?.end_time != nil{
                        sessions.append(t_session!)
                        t_session = nil
                    }
                }
            }

            if t_session?.start_time != nil && t_session?.end_time == nil{
                self.currentSession = t_session
            }
        }
        return sessions
    }
    
//    private func generateSessions(events: [Event]) -> [Session]{
//        var sessions: [Session] = []
//        var t_session = Session()
//        for (_, element) in events.enumerated() {
//            if element.event_time!.equalForStringDate(dateString: "2019-03-19") {
//                print(element.event_time)
//
//            }
//            if element.switcher == .on {
//                t_session = Session()
//                t_session.start_time = element.event_time
//
//            } else {
//                t_session.end_time = element.event_time
//                if (t_session.start_time != nil) {
//                    t_session.period = t_session.end_time?.timeIntervalSince(t_session.start_time!)
//                }
//                if t_session.start_time != nil && t_session.end_time != nil{
//                    sessions.append(t_session)
//                    t_session = nil;
//                }
//            }
//
//            if t_session.start_time != nil && t_session.end_time == nil{
//                self.currentSession = t_session
//            }
//        }
//        return sessions
//    }
    
}
