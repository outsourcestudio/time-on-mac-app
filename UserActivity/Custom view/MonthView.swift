//
//  MonthView.swift
//  UserActivity
//
//  Created by RoboApps on 3/19/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Cocoa

class MonthView: NSView, NibLoadable {
    
    @IBOutlet weak var sessionView: NSView!
    @IBOutlet weak var dayDateLabel: NSTextField!
    var sessionLayers = [CALayer]()
    var sessions = [Session]()
    private var currentMonthDays = 0
    private var currentPeriodDate:Date!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.configView()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.sessionView.wantsLayer = true
//        self.sessionView.layer?.borderWidth = 1
    }
    
    private func configView(){
        let s:CGFloat = 2.0
        var x:CGFloat = 0.0
        let w:CGFloat = (self.sessionView.bounds.width - 30*s) / 31.0
        let h:CGFloat = self.sessionView.bounds.height
        let byDays = sessionsByDays()
        for i in 0 ..< currentMonthDays {
            let layer: CALayer = CALayer()
            layer.frame = NSRect(x: x, y: 0, width: w, height: h)
            if byDays[i+1] != nil {
                layer.backgroundColor = getColor2(interval: byDays[i+1]!).cgColor
            }else{
                layer.backgroundColor = NSColor.hex("#E8EDF6").cgColor
            }
            layer.cornerRadius = 4.0
            layer.masksToBounds = true
            x += w + s
            self.sessionView.layer?.addSublayer(layer)
            sessionLayers.append(layer)
        }
    }
    
    func setSessions(sessions:[Session]){
//        self.sessions = sessions
        let startDate = currentPeriodDate.startOfMonth()
        let days = startDate.getDaysInMonth()
        for i in 1...days {
            let p = Period.periodLastDays(days: -(i-1), from: currentPeriodDate)
            let s = RouterDB().getSessions(period: p)
            self.sessions.append(contentsOf: s)
            if Period.ifTodayInPeriod(period: p) {
                if let sess = createCurrentSession(period: p) {
                    self.sessions.append(sess)
                }
            }
        }
        
        
    }
    
    func setCurrentMonthDays(date:Date){
        currentPeriodDate = date
        currentMonthDays = date.getDaysInMonth()
        dayDateLabel.stringValue = date.toString(format: "MMM").capitalized
    }
    
    func sessionsByDays() -> [Int:TimeInterval] {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        
        var array = [Int:TimeInterval]()
        sessions.forEach { (session) in
            let days = calendar.component(.day, from: session.start_time)
//            print(days, session.start_time!, session.end_time!, session.period!, session.period!.intervalAsList())
            if let period = session.period {
                if let s = array[days] {
                    array[days] = s + period
                }else{
                    array[days] = period
                }
            }
        }
        return array
    }
    
    private func randomColor() -> NSColor{
        let a = [NSColor.hex("#e8edf6"), NSColor.hex("#5063ff"), NSColor.hex("#9cc0ff")]
        return a[Int.random(in: 0..<a.count)]
    }
    
    func getColor2(interval:TimeInterval) -> NSColor{
        
        if interval >= 0 && interval < 2*60*60 { // 2 часа
            return NSColor.hex("#96A1FF")
        }
        
        if interval >= 2*60*60 && interval < 6*60*60 { // 2 - 6 часа
            return NSColor.hex("#7282FF")
        }
        
        if interval >= 6*60*60 && interval < 12*60*60 { // 6 - 12 часа
            return NSColor.hex("#5063FF")
        }
        
        if interval >= 12*60*60 { // более 12 часа
            return NSColor.hex("#3742FA")
        }
        
        return NSColor.hex("#E8EDF6")
    }
    
    private func getColor(interval:TimeInterval) -> NSColor{
        let c = NSColor.hex("#0028dd")
        let percent:CGFloat = CGFloat(interval) / 86400.0 * 100.0
        if let newColor = c.adjust(by: percent) {
            return newColor
        }
        return c
    }
}
