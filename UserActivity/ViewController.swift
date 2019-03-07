//
//  ViewController.swift
//  UserActivity
//
//  Created by Sergiy Kurash on 3/1/19.
//  Copyright © 2019 Sergiy Kurash. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var insight_main_date: NSTextField!
    
    @IBOutlet var logField: NSTextView!
    @IBOutlet weak var summedBox: NSBox!
    @IBOutlet weak var total_time: NSTextField!
    @IBOutlet weak var total_sessions: NSTextField!
    @IBOutlet weak var longest_session_time: NSTextField!
    var dayView:DayView?
    var weekView = [DayView]()
//    var mainDB: Database!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController viewDidLoad")
        
//        logField.string = "pmset -g log|grep -e \" Notification \""
//        logField.string += "\n\n\n"
        logField.string += Bash.shell("pmset -g log|grep -e \" Notification \"")
        
        setCurrentDate()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func setCurrentDate() {
//        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let date = Date()
        insight_main_date.stringValue = date.monthAsString()
        
        let period = Period(start: Period.periodLastDays(days: 365).startDate, end: Date())
        updateSummedValues(period: period)
    }
    
    func updateSummedValues(period:Period){
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let currentPeriod = Date().timeIntervalSince(appDelegate.mainDB.currentSession!.start_time!)
        let sessions = appDelegate.mainDB.getSessions(period: period)
        
//        if sessions.count + 1 > 0{
            total_sessions.stringValue = "\(sessions.count + 1) sessions"
//        }else{
//            total_sessions.stringValue = "not found sessions"
//        }
        
        var allTime:TimeInterval = 0
        for session in sessions {
            allTime += session.period ?? 0
        }
        allTime += currentPeriod
        
        var (h,m,_) = allTime.intervalAsList()
        total_time.stringValue = String(format: "%0.2d hours %0.2d minutes",h,m)
        
        (h,m,_) = appDelegate.mainDB.maxPerid(period: period).intervalAsList()
        longest_session_time.stringValue = String(format: "%0.2dh %0.2dm longest",h,m)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.mainWindowController = nil
    }
    
    @IBAction func yearAction(_ sender: Any) {
        self.clearViews()
        let period = Period(start: Period.periodLastDays(days: 365).startDate, end: Date())
        updateSummedValues(period: period)
    }
    
    @IBAction func monthAction(_ sender: Any) {
        self.clearViews()
        let period = Period(start: Period.periodLastDays(days: 30).startDate, end: Date())
        updateSummedValues(period: period)
    }
    
    @IBAction func weekAction(_ sender: Any) {
        self.clearViews()
        
        if self.weekView.count == 0 {
            let size = NSSize(width: self.view.bounds.width - 100, height: 65)
            var y:CGFloat = self.summedBox.frame.origin.y - size.height - 20.0
            for i in 1..<8 {
                let day = DayView.createFromNib()!
                day.frame = NSRect(x: 50, y: y, width: size.width, height: size.height)
                day.wantsLayer = true
                
                self.view.addSubview(day)
                
                let appDelegate = NSApplication.shared.delegate as! AppDelegate
                let period = Period.periodLastDays(days: i)
                var sessions = appDelegate.mainDB.getSessions(period: period)
                let nowSession = Session()
                nowSession.start_time = appDelegate.mainDB.currentSession.start_time!
                nowSession.end_time = Date()
                sessions.append(nowSession)
                day.setSessions(sessions: sessions)
                day.setDateLabel(date: period.endDate)
                y -= (10 + size.height)
                self.weekView.append(day)
            }
        }else{
            self.weekView.forEach({ (day) in
                day.isHidden = false
            })
        }
        let period = Period(start: Period.periodLastDays(days: 7).startDate, end: Date())
        updateSummedValues(period: period)
    }
    
    @IBAction func dayAction(_ sender: Any) {
        self.clearViews()
        
        if dayView?.superview == nil {
            let size = NSSize(width: self.view.bounds.width - 100, height: 65)
            dayView = DayView.createFromNib()!
            dayView?.frame = NSRect(x: 50, y: self.summedBox.frame.origin.y - size.height - 20.0, width: size.width, height: size.height)
            dayView?.wantsLayer = true
//            dayView?.layer?.borderWidth = 1
            
            self.view.addSubview(dayView!)
            
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            var sessions = appDelegate.mainDB.getSessions(period: Period.todayPeriod())
            let nowSession = Session()
            nowSession.start_time = appDelegate.mainDB.currentSession.start_time!
            nowSession.end_time = Date()
            sessions.append(nowSession)
            dayView?.setSessions(sessions: sessions)
            dayView?.setDateLabel(date: Period.todayPeriod().endDate)
        }else{
            dayView?.isHidden = false
        }
        
        let period = Period(start: Period.todayPeriod().startDate, end: Date())
        updateSummedValues(period: period)
    }
    
    private func clearViews(){
        dayView?.isHidden = true
        self.weekView.forEach({ (day) in
            day.isHidden = true
        })
    }
    
}



