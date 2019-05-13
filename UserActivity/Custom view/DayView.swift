//
//  DayView.swift
//  UserActivity
//
//  Created by RoboApps on 3/5/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Cocoa

class DayView: NSView, NibLoadable {

    @IBOutlet weak var sessionView: NSView!
    @IBOutlet weak var dayDateLabel: NSTextField!
    @IBOutlet weak var hoursLabel: NSTextField!
    public var filledColor:NSColor = NSColor.hex("#5063ff")
    var sessionLayers = [CALayer]()
    var sessions = [Session]()
    private var borderLayer = CALayer()
    
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
        self.sessionView.layer?.backgroundColor = NSColor.hex("#e8edf6").cgColor
        self.sessionView.layer?.cornerRadius = 10.0
        configSessionViews()
    }
    
    private func configSessionViews(){
        self.clearSessions()

        let h:CGFloat = self.sessionView.bounds.height - 6
        let y1:CGFloat = self.sessionView.bounds.height/2 - 2.5
        var y:CGFloat = 0
        var s:CGFloat = 0
//        print("--------")
        sessions.forEach { (session) in
            let layer: CALayer = CALayer()
            var (xx,ww) = convertDateToLine(width: self.sessionView.bounds.width - 6.0, session: session)
            ww = ww < 0.1 ? 2 : ww
//            if Int(session.period!) > 120 {
                layer.frame = NSRect(x: 3 + xx + s, y: y + 3, width: ww, height: h)
//            } else {
//                layer.frame = NSRect(x: 3 + xx + s, y: y1, width: 5, height: 5)
//                s += 5 - ww
//            }
//            print(self.sessionView.frame.width, layer.frame.origin.x, layer.frame.origin.x + ww)
//            print(session.start_time!.toString(format: "HH:mm"), session.period!)
            layer.backgroundColor =  filledColor.cgColor
            layer.cornerRadius = 7

            if ww < 25 {
                layer.cornerRadius = 3
            }
            if ww < 1 {
                layer.cornerRadius = 0
            }
//            y += 10
            self.sessionView.layer?.addSublayer(layer)
            sessionLayers.append(layer)
        }
//        print("--------")
        
        var allTime:TimeInterval = 0
        for session in sessions {
            allTime += session.period ?? 0
        }
        let (hh,mm,_) = allTime.intervalAsList()
        if hh > 0 {
            hoursLabel.stringValue = String(format: "%0.2d",hh) + "hr".localized()  + " " + String(format: "%0.2d",mm) + "m".localized()
        }else{
            hoursLabel.stringValue = String(format: "%0.2d",mm) + "m".localized()
        }
        if hh == 0 && mm == 0 {
            hoursLabel.stringValue = ""
        }
        
        borderLayer.frame = NSRect(x: 0, y: 0, width: self.sessionView.bounds.width, height: self.sessionView.bounds.height)
        borderLayer.borderWidth = 3
        borderLayer.borderColor = /*NSColor.black.cgColor */NSColor.hex("#e8edf6").cgColor
        borderLayer.cornerRadius = self.sessionView.layer!.cornerRadius
        self.sessionView.layer?.addSublayer(borderLayer)
        
    }
    
    func setSessions(sessions:[Session]){
        self.sessions = sessions
    }
 
    private func clearSessions(){
        sessionLayers.forEach { (layer) in
            layer.removeFromSuperlayer()
        }
        sessionLayers.removeAll()
        borderLayer.removeFromSuperlayer()
    }
    
    
}
