
//
//  TrianleView.swift
//  UserActivity
//
//  Created by RoboApps on 3/26/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Cocoa
import RealmSwift

class TrianleView: NSView, NibLoadable {

    @IBOutlet weak var bgView: NSView!
    @IBOutlet weak var bottomView: NSView!
    @IBOutlet weak var topView: NSView!
    @IBOutlet weak var triView: NSView!
    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var timeSecLabel: NSTextField!
    private var views = [NSView]()
    let shapeLayer = CAShapeLayer()
    static let rows = 5
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        bgView.wantsLayer = true
        bgView.layer?.backgroundColor = NSColor.init(white: 1, alpha: 0.15).cgColor
        
        topView.wantsLayer = true
        topView.layer?.backgroundColor = NSColor.hex("#303956").cgColor
        topView.layer?.cornerRadius = 15.0
        topView.layer?.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        bottomView.wantsLayer = true
        bottomView.layer?.backgroundColor = NSColor.hex("#303956").cgColor
        bottomView.layer?.cornerRadius = 15.0
        bottomView.layer?.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let view = TriView()
        view.frame = triView.bounds
        
        triView.addSubview(view)
    }
    
    func configView(){
        clearAll()
        timeLabel.stringValue = "12:39 - 15:04"
        timeSecLabel.stringValue = "30 min"
        
        let x:CGFloat = 15
        var y:CGFloat = 28
        let w:CGFloat = self.frame.width - x * 2
        let h:CGFloat = 35
        let sp:CGFloat = 10
        
        for i in 0..<3 {
            let v = DetailPopupInfoView.createFromNib()!
            v.frame = NSRect(x: x, y: y, width: w, height: h)
            v.appName.stringValue = "MS Word " + "\(i)"
            self.addSubview(v)
            views.append(v)
            y += h + sp
        }
    }
    
//    func configView(sessions:[SessionItem], rowCount: Int = TrianleView.rows){
//        clearAll()
//        let realm = try! Realm()
//
//        var allSessionsPeriod:TimeInterval = 0
//        sessions.forEach { (s) in
//            allSessionsPeriod += s.endDate.timeIntervalSince(s.startDate)
//        }
//        var allAppsCounts:TimeInterval = 0
//        var allApps = [String : TimeInterval]()
//        sessions.forEach { (s) in
//            allAppsCounts += s.allAppsCounts()
//            s.apps.forEach({ (a) in
//                if allApps[a.appID] != nil {
//                    allApps[a.appID] = allApps[a.appID]! + a.count
//                }else{
//                    allApps[a.appID] = a.count
//                }
//            })
//        }
//        let sorted = allApps.sorted { $0.1 < $1.1 }
//
//
//        let (hh,mm,ss) = allSessionsPeriod.intervalAsList()
//        if hh > 0 {
//            timeSecLabel.stringValue = String(format: "%0.2d",hh) + "hr".localized()  + " " + String(format: "%0.2d",mm) + "m".localized()
//        }else if hh == 0 && mm == 0 && ss > 0{
//            timeSecLabel.stringValue = String(format: "%0.2d",ss)  + " " + "s".localized()
//        }else{
//            timeSecLabel.stringValue = String(format: "%0.2d",mm)  + " " + "m".localized()
//        }
//        if sessions.count > 1 {
//            timeLabel.stringValue = "\(sessions.count) " + "sessions".localized()
//        }else if sessions.count != 0 {
//            timeLabel.stringValue = sessions[0].startDate.toString(format: "HH:mm") + " - " + sessions[0].endDate.toString(format: "HH:mm")
//        }else{
//            timeLabel.stringValue = "00:00 - 00:00"//session.startDate.toString(format: "HH:mm") + " - " + session.endDate.toString(format: "HH:mm")
//        }
//
//        let x:CGFloat = 15
//        var y:CGFloat = 28
//        let w:CGFloat = self.frame.width - x * 2
//        let h:CGFloat = 35
//        let sp:CGFloat = 10
//        print(" --------- ")
//        var index = 0
//        sorted.forEach { (k,val) in
//            if index < rowCount, let item = realm.objects(AppInfoItem.self).filter("appID == '\(k)'").first {
//                let v = DetailPopupInfoView.createFromNib()!
//                v.frame = NSRect(x: x, y: y, width: w, height: h)
//                v.appName.stringValue = item.appName!// + " \(app.count)"
//                let pers:TimeInterval = TimeInterval(val) / allAppsCounts * 100
//                print(allSessionsPeriod, val, pers)
//
//                let (hh,mm,ss) = TimeInterval(allSessionsPeriod * pers / 100.0).intervalAsList()
//                if hh > 0 {
//                    v.appTime.stringValue = String(format: "%0.2d",hh) + "hr".localized()  + " " + String(format: "%0.2d",mm) + "m".localized() + " (\(Int(pers))%)"
//                }else if hh == 0 && mm == 0 && ss > 0{
//                    v.appTime.stringValue = String(format: "%0.2d",ss) + " " + "sec".localized() + " (\(Int(pers))%)"
//                }else{
//                    v.appTime.stringValue = String(format: "%0.2d",mm) + " " + "min".localized() + " (\(Int(pers))%)"
//                }
//
//                loadImg(img: v.appIcon, url: item.appIcon!)
//                self.addSubview(v)
//                views.append(v)
//                y += h + sp
//                index += 1
//            }
//        }
//        print(" ======== ")
//    }
    
    
    func configView(session:SessionItem, rowCount: Int = TrianleView.rows){
        clearAll()
        let realm = try! Realm()
        var sortedApps = Array(session.apps.sorted(byKeyPath: "count", ascending: false))
        if sortedApps.count > rowCount {
            sortedApps = Array(sortedApps[0 ..< rowCount])
        }
        sortedApps = sortedApps.sorted(by: { (a1, a2) -> Bool in
            return a1.count < a2.count
        })

        let allSessionIntervals = session.endDate!.timeIntervalSince(session.startDate) > 0 ? session.endDate!.timeIntervalSince(session.startDate) : 1
        let allAppsCouns = session.allAppsCounts()

        let (hh,mm,ss) = allSessionIntervals.intervalAsList()
        if hh > 0 {
            timeSecLabel.stringValue = String(format: "%0.2d",hh) + "hr".localized()  + " " + String(format: "%0.2d",mm) + "m".localized()
        }else if hh == 0 && mm == 0 && ss > 0{
            timeSecLabel.stringValue = String(format: "%0.2d",ss)  + " " + "s".localized()
        }else{
            timeSecLabel.stringValue = String(format: "%0.2d",mm)  + " " + "m".localized()
        }

        timeLabel.stringValue = session.startDate.toString(format: "HH:mm") + " - " + session.endDate!.toString(format: "HH:mm")

        let x:CGFloat = 15
        var y:CGFloat = 28
        let w:CGFloat = self.frame.width - x * 2
        let h:CGFloat = 35
        let sp:CGFloat = 10
//        print(" --------- ")
        for (index, app) in sortedApps.enumerated() {
            if let item = realm.objects(AppInfoItem.self).filter("appID == '\(app.appID!)'").first {
//                let valKoef = TimeInterval(app.count)// / AppManager.activityAppTimerPeriod
                let v = DetailPopupInfoView.createFromNib()!
                v.frame = NSRect(x: x, y: y, width: w, height: h)
                v.appName.stringValue = item.appName!// + " \(app.count)"
                let pers:TimeInterval = TimeInterval(app.count) / allAppsCouns * 100
                print(allSessionIntervals, app.count, pers)

                let (hh,mm,ss) = TimeInterval(allSessionIntervals * pers / 100.0).intervalAsList()
                if hh > 0 {
                    v.appTime.stringValue = String(format: "%0.2d",hh) + "hr".localized()  + " " + String(format: "%0.2d",mm) + "m".localized() + " (\(Int(pers))%)"
                }else if hh == 0 && mm == 0 && ss > 0{
                    v.appTime.stringValue = String(format: "%0.2d",ss) + " " + "sec".localized() + " (\(Int(pers))%)"
                }else{
                    v.appTime.stringValue = String(format: "%0.2d",mm) + " " + "min".localized() + " (\(Int(pers))%)"
                }

                loadImg(img: v.appIcon, url: item.appIcon!)
                self.addSubview(v)
                views.append(v)
                y += h + sp
                if index > (rowCount - 1) { break }
            }
        }
//        print(" ======== ")
    }
    
    private func loadImg(img:NSImageView, url:String){
        if let image = NSImage(contentsOf: URL(string: url)!) {
            img.image = image
            img.layer?.backgroundColor = NSColor.clear.cgColor
        }else{
            img.wantsLayer = true
            img.layer?.masksToBounds = true
            img.layer?.cornerRadius = img.bounds.width / 2.0
            img.layer?.backgroundColor = NSColor.init(white: 1, alpha: 0.3).cgColor

        }
    }
    
    private func clearAll(){
        views.forEach { (v) in
            v.removeFromSuperview()
        }
        views.removeAll()
    }
    
}

class TriView: NSView {

    let shapeLayer = CAShapeLayer()
    
    override func draw(_ dirtyRect: NSRect) {
        
        self.wantsLayer = true
        
        // Get Height and Width
        let layerHeight = self.layer!.frame.height
        let layerWidth = self.layer!.frame.width
        
        // Create Path
        let bezierPath = NSBezierPath()
        
        // Draw Points
        bezierPath.move(to: CGPoint(x: 0, y: layerHeight))
        bezierPath.line(to: CGPoint(x: layerWidth, y: layerHeight))
        bezierPath.line(to: CGPoint(x: layerWidth / 2, y: 0))
        bezierPath.line(to: CGPoint(x: 0, y: layerHeight))
        bezierPath.close()
        
        // Apply Color
        NSColor.hex("#303956").setFill()
        bezierPath.fill()
        
        // Mask to Path
        
        shapeLayer.path = bezierPath.cgPath
        self.layer!.mask = shapeLayer

        
    }
    
}
