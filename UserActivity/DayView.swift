//
//  DayView.swift
//  UserActivity
//
//  Created by toxa on 3/5/19.
//  Copyright © 2019 Sergiy Kurash. All rights reserved.
//

import Cocoa

class DayView: NSView, NibLoadable {

    @IBOutlet weak var sessionView: NSView!
    @IBOutlet weak var dayDateLabel: NSTextField!
    public var filledColor:NSColor = NSColor(red: 51.0/255.0, green: 102.0/255.0, blue: 203.0/255.0, alpha: 1.0)
    private var sessionLayers = [CALayer]()
    private var sessions = [Session]()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        print("DayView draw")
        self.configView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sessionView.wantsLayer = true
        self.sessionView.layer?.borderWidth = 1
    }
    
    private func configView(){
        var x:CGFloat = 0
        let w:CGFloat = self.sessionView.bounds.width / 24.0
        let h:CGFloat = self.sessionView.bounds.height
        for i in 0 ..< 24 {
            let layer: CALayer = CALayer()
            layer.frame = NSRect(x: x, y: 0, width: w, height: h)
            layer.backgroundColor =  i % 2 == 0 ? NSColor.lightGray.cgColor : NSColor.white.cgColor
            x += w
            self.sessionView.layer?.addSublayer(layer)
        }
        configSessionViews()
    }
    
    private func configSessionViews(){
        self.clearSessions()

        let h:CGFloat = self.sessionView.bounds.height
        sessions.forEach { (session) in
            let layer: CALayer = CALayer()
            let (xx,ww) = convertDateToLine(session: session)
            layer.frame = NSRect(x: xx, y: 0, width: ww, height: h)
            layer.backgroundColor =  filledColor.cgColor
            self.sessionView.layer?.addSublayer(layer)
            sessionLayers.append(layer)
        }
    }
    
    private func convertDateToLine(session:Session) -> (x:CGFloat, w:CGFloat) {
        let step:CGFloat = self.sessionView.bounds.width / 86400
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
//            print(finalX, finalWidth)
            return (finalX, finalWidth)
        }
        return (0,0)
    }
    func setDateLabel(date:Date){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        dayDateLabel.stringValue = dateFormatter.string(from: date)
    }
    
    func setSessions(sessions:[Session]){
        self.sessions = sessions
    }
 
    private func clearSessions(){
        sessionLayers.forEach { (layer) in
            layer.removeFromSuperlayer()
        }
        sessionLayers.removeAll()
    }
    
    
}
