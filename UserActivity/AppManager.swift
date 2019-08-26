//
//  Model.swift
//  TimeMatters
//
//  Created by toxa on 6/20/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Foundation
import RealmSwift

class AppManager:NSObject {
    static let shared: AppManager = AppManager()
    private let mainAppTimerPeriod:TimeInterval = 15
    static let activityAppTimerPeriod:TimeInterval = 2.0
    private var currentKey:TimeInterval = 0
    private var lastCheckDate = Date(timeIntervalSince1970: 0)
    
    var mainAppTimer:Timer?
    var activityAppTimer:Timer?
    let bannedApps:[String] = ["loginwindow", "ScreenSaver"]
    
    func start(){
        
        mainAppTimer?.invalidate()
        activityAppTimer?.invalidate()
        
//        checkActiveSession()
        
//        mainAppTimer = Timer.scheduledTimer(timeInterval: mainAppTimerPeriod, target: self, selector: #selector(mainTimerAction), userInfo: nil, repeats: true)
        activityAppTimer = Timer.scheduledTimer(timeInterval: AppManager.activityAppTimerPeriod, target: self, selector: #selector(activityTimerAction), userInfo: nil, repeats: true)
    }
    
    @objc private func mainTimerAction(){
        print("mainTimerAction")
        checkActiveSession()
        NotificationCenter.default.post(name: NSNotification.Name("DatabaseHasChanged"), object: nil)
    }
    
    @objc private func activityTimerAction(){
        
        let date = Date()
        let key = date.timeIntervalSince1970
        let oldKey = lastCheckDate.timeIntervalSince1970
        let realm = try! Realm()
        let workspace = NSWorkspace.shared
        let applications = workspace.runningApplications
        let currentSession = realm.objects(SessionItem.self).filter("id == '\(self.currentKey)'").first
        
        if let app = applications.filter({$0.isActive}).first {
            createAppInfo(app: app)
            if !isBannedApp(appID: app.bundleIdentifier ) {
                if currentSession != nil && (key - oldKey < 20) && currentSession?.stopped == false {
                    let appIdf = app.bundleIdentifier ?? ""
                    if let appItem = currentSession!.apps.filter("appID == '\(appIdf)'").first {
                        try! realm.write {
                            appItem.count += AppManager.activityAppTimerPeriod
                        }
                    }else{
                        let appItem = ActivityAppStatusItem()
                        appItem.appID = app.bundleIdentifier
                        try! realm.write {
                            currentSession!.apps.append(appItem)
                        }
                    }
                    try! realm.write {
                        currentSession!.endDate = date
                    }
                }else{
                    createSession(dat:date)
                }
            }else{
                if currentSession != nil && currentSession?.stopped == false {
                    try! realm.write {
                        currentSession!.stopped = true
                    }
                }
            }
            
        }
        lastCheckDate = date
        
    }
    
    private func checkActiveSession(){
        let realm = try! Realm()
        let date = Date()
        let key = date.timeIntervalSince1970
        let old = lastCheckDate.timeIntervalSince1970
        if key - old > 35 {
            createSession(dat: date)
        }else{
            if let item = realm.objects(SessionItem.self).filter("id == '\(self.currentKey)'").first {
                try! realm.write {
                    item.endDate = date
                }
            }
        }
        lastCheckDate = date
    }

    
    private func createAppInfo(app:NSRunningApplication){
        let realm = try! Realm()
        let appInfo = AppInfoItem()
        appInfo.appID = app.bundleIdentifier ?? ""
        appInfo.appName = app.localizedName ?? ""
        appInfo.appIcon = app.icon?.doSave(name: appInfo.appName! )?.absoluteString
        try! realm.write {
            realm.add(appInfo, update: true)
        }
    }
    
    private func createSession(dat:Date){
        let key = dat.timeIntervalSince1970
        let realm = try! Realm()
        let item = SessionItem()
        item.startDate = dat
        item.endDate = dat//Date(timeIntervalSince1970: date.timeIntervalSince1970)
        item.id = "\(key)"
        try! realm.write {
            realm.add(item)
        }
        currentKey = key
    }
    
    func getSessionList(period:Period? = nil) -> [SessionItem] {
        func createNewSession(s:SessionItem) -> SessionItem{
            let temp = SessionItem()
            temp.id = s.id
            temp.startDate = s.startDate
            temp.endDate = s.endDate
            temp.apps = s.apps
            temp.stopped = s.stopped
            temp.period = temp.endDate!.timeIntervalSince(temp.startDate)
            return temp
        }
        
        var resultArray = [SessionItem]()
        let realm = try! Realm()
        let objs = realm.objects(SessionItem.self).sorted(byKeyPath: "startDate")
        var a = Array(objs)
        if period == nil {
            a.forEach { (s) in
                let temp = createNewSession(s: s)
                if temp.endDate! > period!.endDate {
                    temp.endDate = period!.endDate
                    temp.period = s.endDate!.timeIntervalSince(temp.startDate!)
                }
                if temp.startDate < period!.startDate {
                    temp.startDate = period!.startDate
                    temp.period = temp.endDate?.timeIntervalSince(temp.startDate!)
                }
                resultArray.append(temp)
            }
            resultArray = resultArray.filter({ (s) -> Bool in
                return s.period! > 0.1
            })
            return resultArray
        }else{
            a = a.filter { (sesItem) -> Bool in
                return sesItem.endDate! >= period!.startDate && sesItem.startDate <= period!.endDate
            }
            a.forEach { (s) in
                let temp = createNewSession(s: s)
                if temp.endDate! > period!.endDate {
                    temp.endDate = period!.endDate
                    temp.period = temp.endDate!.timeIntervalSince(temp.startDate!)
                }
                if temp.startDate < period!.startDate {
                    temp.startDate = period!.startDate
                    temp.period = temp.endDate?.timeIntervalSince(temp.startDate!)
                }
                resultArray.append(temp)
            }
            resultArray = resultArray.filter({ (s) -> Bool in
                return s.period! > 0.1
            })
            return resultArray
        }
    }
    
    private func isBannedApp(appID:String?) -> Bool{
        guard let appID = appID else {
            return false
        }
        var b = false
        for (_, bannedApp) in bannedApps.enumerated() {
            if appID.contains(bannedApp){
                print("banned ", appID)
                b = true
                break
            }
        }
        
        return b
    }
    
    //MARK: -
    func createAndAddFakeSessions(){
        return;
        let realm = try! Realm()
        let start = "20.06.2019"
        let a = [10000, 50000, 99099, 20000, 60000, 6050, 7000, 29000, 1300]
        let calendar = Calendar.current
        
        if var startDate = start.toDate(format: "dd.MM.yyyy") {
            for i in 0..<15 {
                let item = SessionItem()
                item.id = "\(startDate.timeIntervalSince1970)"
                item.startDate = startDate
                let c = a.count
                let rand = a[ Int.random(in: 0..<c) ]
                let endDate = calendar.date(byAdding: .second, value: rand, to: startDate)!
                item.endDate = endDate
                print("----")
                print(startDate)
                print(endDate)
                print("====")
                try! realm.write {
                    realm.add(item)
                }
                startDate = calendar.date(byAdding: .second, value: 3000, to: endDate)!
            }
        }
        print("done createAndAddFakeSessions")
    }

}

class SessionItem:Object {
    @objc dynamic var id:String!
    @objc dynamic var startDate:Date!
    @objc dynamic var endDate:Date!
    @objc dynamic var stopped:Bool = false
    var apps = List<ActivityAppStatusItem>()
    var period: TimeInterval?
    
    func allAppsCounts() -> TimeInterval{
        var c:TimeInterval = 0
        apps.forEach { (a) in
            c += a.count
        }
        return c
    }
}

class ActivityAppStatusItem:Object {
    @objc dynamic var appID:String!
    @objc dynamic var count:TimeInterval = 1
//    var percents:TimeInterval = 0
}

class AppInfoItem:Object {
    @objc dynamic var appID:String!
    @objc dynamic var appIcon:String?
    @objc dynamic var appName:String?
    
    override static func primaryKey() -> String? {
        return "appID"
    }
}


extension NSImage {
    
    func doSave(name:String) -> URL?{
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("\(name).png")
        
        guard
            let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)
            else { return nil }
        let newRep = NSBitmapImageRep(cgImage: cgImage)
        newRep.size = self.size // if you want the same size
        guard
            let pngData = newRep.representation(using: .png, properties: [:])
            else { return nil }
        do {
            try pngData.write(to: fileURL)
            return fileURL
        }
        catch {
            print("error saving: \(error)")
            return nil
        }

    }
    
    
}
