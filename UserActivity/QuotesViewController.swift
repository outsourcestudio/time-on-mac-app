//
//  QuotesViewController.swift
//  UserActivity
//
//  Created by toxa on 3/4/19.
//  Copyright © 2019 Sergiy Kurash. All rights reserved.
//

import Cocoa

class QuotesViewController: NSViewController {

    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var lastLoginLabel: NSTextField!
    @IBOutlet weak var allDataBtn: NSButton!
    @IBOutlet weak var sessionsCount: NSTextField!
    @IBOutlet weak var sessionsTimelabel: NSTextField!
    @IBOutlet weak var longestSessionsTimelabel: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("QuotesViewController viewDidLoad")
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
//        print("QuotesViewController viewWillAppear")
        self.configViews()
    }
    
//    override func viewDidAppear() {
//        super.viewDidAppear()
//        print("QuotesViewController viewDidAppear")
//    }
    
    func configViews(){
        
        return
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        if appDelegate.mainDB.loading == true {
            self.spinner.startAnimation(self)
        }else{
            self.spinner.stopAnimation(self)
        }
        let currentPeriod = Date().timeIntervalSince(appDelegate.mainDB.currentSession!.start_time!)
        let sessions = appDelegate.mainDB.getSessions(period: Period.todayPeriod())
        
        sessionsCount.stringValue = "\(sessions.count + 1)"
        
        var allTime:TimeInterval = 0
        for session in sessions {
            allTime += session.period ?? 0
        }
        allTime += currentPeriod
        
        var (h,m,_) = allTime.intervalAsList()
        if h > 0 {
            sessionsTimelabel.stringValue = String(format: "%0.2dh %0.2dm",h,m)
        }else{
            sessionsTimelabel.stringValue = String(format: "%0.2dm",m)
        }
        
        
        let maxPeriod = appDelegate.mainDB.maxPerid(period: Period.todayPeriod())
        
        (h,m,_) = max(currentPeriod, maxPeriod).intervalAsList()
        if h > 0 {
            longestSessionsTimelabel.stringValue = String(format: "Longest session %0.2dh %0.2dm",h,m)
        }else{
            longestSessionsTimelabel.stringValue = String(format: "Longest session %0.2dm",m)
        }
        
        let calendar = Calendar.current
        var sub = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-ddHH:mm"
        
        if let ses = appDelegate.mainDB.currentSession, let start = ses.start_time {
            if calendar.isDateInToday(start) {
                sub = "today"
                dateFormatter.dateFormat = "HH:mm"
            }else if calendar.isDateInYesterday(start) {
                sub = "yesterday"
                dateFormatter.dateFormat = "HH:mm"
            }
            lastLoginLabel.stringValue = "Last login: \(sub) \(dateFormatter.string(from: start)) \(NSUserName())"
        }
        
    }
    
    @IBAction func allDataAction(_ sender: Any) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.showMainWindow()
    }
    
}


extension QuotesViewController {
    static func freshController() -> QuotesViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: "QuotesViewController") as? QuotesViewController else {
            fatalError("Why cant i find QuotesViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
