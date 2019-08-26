//
//  Functions.swift
//  UserActivity
//
//  Created by RoboApps on 3/12/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Foundation
import Cocoa
import RealmSwift
import Collaboration


func setDocIconVisibility(state:Bool){
    var transformState: ProcessApplicationTransformState
    if state { // show
        transformState = ProcessApplicationTransformState(kProcessTransformToForegroundApplication)
    }else{ //hide
        transformState = ProcessApplicationTransformState(kProcessTransformToUIElementApplication)
    }
    var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
    TransformProcessType(&psn, transformState)
}

func saveStrToFile(fileName:String, text:String){
    
    let file = fileName //this is the file. we will write to and read from it
    
//    let text = "some text" //just a text
    
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        print(dir)
        let fileURL = dir.appendingPathComponent(file)
        
        //writing
        do {
            try text.write(to: fileURL, atomically: false, encoding: .utf8)
        }
        catch {/* error handling here */}
        
        //reading
        do {
            _ = try String(contentsOf: fileURL, encoding: .utf8)
        }
        catch {/* error handling here */}
    }
    
}

func convertDateToLine(width:CGFloat, session:Session) -> (x:CGFloat, w:CGFloat) {
    let step:CGFloat = width / 86400
    var finalX:CGFloat = 0
    var finalWidth:CGFloat = 0
    let calendar = Calendar.current
    if let start = session.start_time, let end = session.end_time {
        var components = calendar.dateComponents([.hour,.minute,.second], from: start)
        let secsStart:CGFloat = CGFloat(components.hour! * 3600) + CGFloat(components.minute! * 60) + CGFloat(components.second!)
        components = calendar.dateComponents([.hour,.minute,.second], from: end)
        let secsEnd:CGFloat = CGFloat(components.hour! * 3600) + CGFloat(components.minute! * 60) + CGFloat(components.second!)
        finalX = secsStart * step
        finalWidth = secsEnd * step - finalX
        return (finalX, finalWidth)
    }
    return (0,0)
}

func convertDateToLine(width:CGFloat, session:SessionItem) -> (x:CGFloat, w:CGFloat) {
    let step:CGFloat = width / 86400
    var finalX:CGFloat = 0
    var finalWidth:CGFloat = 0
    let calendar = Calendar.current
    if let start = session.startDate, let end = session.endDate {
        var components = calendar.dateComponents([.hour,.minute,.second], from: start)
        let secsStart:CGFloat = CGFloat(components.hour! * 3600) + CGFloat(components.minute! * 60) + CGFloat(components.second!)
        components = calendar.dateComponents([.hour,.minute,.second], from: end)
        let secsEnd:CGFloat = CGFloat(components.hour! * 3600) + CGFloat(components.minute! * 60) + CGFloat(components.second!)
        finalX = secsStart * step
        finalWidth = secsEnd * step - finalX
        return (finalX, finalWidth)
    }
    return (0,0)
}

func getUserImage() -> NSImage? {
    let identity:CBIdentity = CBIdentity(name: NSUserName(), authority: CBIdentityAuthority.default())!
    return identity.image
}

func OSXVersion(){
    print(ProcessInfo.processInfo.operatingSystemVersion)
    print(Realm.Configuration.defaultConfiguration.fileURL!)
}

func createCurrentSession(period:Period)->Session? {
    let secs:Double = 300
    if let dat = UserDefaults.standard.value(forKey: "updateDate") as? Date{
        let updateInterval = dat.timeIntervalSince1970
        let dateInterval = Date().timeIntervalSince1970
        
        if dateInterval - updateInterval > secs {
            return nil
        }
    }else{
        return nil
    }
    
    if let cur = RouterDB().getCurrentSession() {
        let nowSession = cur
        nowSession.end_time = Date()
        nowSession.period = nowSession.end_time?.timeIntervalSince(nowSession.start_time!)

        if nowSession.end_time! > period.endDate {
            nowSession.end_time = period.endDate
            nowSession.period = nowSession.end_time?.timeIntervalSince(nowSession.start_time!)
        }
        if nowSession.start_time < period.startDate {
            nowSession.start_time = period.startDate
            nowSession.period = nowSession.end_time?.timeIntervalSince(nowSession.start_time!)
        }

        return nowSession
    }
    
    return nil
}

func maxPerid(sessions:[Session]) -> TimeInterval {
    let a = sessions.sorted { (s1, s2) -> Bool in
        let p1 = s1.period ?? 0
        let p2 = s2.period ?? 0
        return p1 < p2
        }.last
    return a?.period ?? 0
}

func maxPerid(sessions:[SessionItem]) -> TimeInterval {
    let a = sessions.sorted { (s1, s2) -> Bool in
        let p1 = s1.period ?? 0
        let p2 = s2.period ?? 0
        return p1 < p2
        }.last
    return a?.period ?? 0
}


func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}


func notifFromFile()->String{
    var s = ""
    if let file = Bundle.main.path(forResource: "Notification", ofType: "txt"), let content = try? String(contentsOfFile: file, encoding: .utf8) {
        s = content
    }
    
    return s
}

func lastUserFromFile()->String{
    var s = ""
    if let file = Bundle.main.path(forResource: "last", ofType: "txt"), let content = try? String(contentsOfFile: file, encoding: .utf8) {
        s = content
    }
    
    return s
}
