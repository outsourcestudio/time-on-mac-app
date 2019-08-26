//
//  TodayProgressView.swift
//  UserActivity
//
//  Created by RoboApps on 3/17/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Cocoa

protocol TodayProgressViewDelegate: class {
    func showPopupView(session:SessionItem, point: NSPoint)
    func hidePopupView()
}

class TodayProgressView: NSView, NibLoadable {

    @IBOutlet weak var sessionView: NSView!
    private var sessionLayers = [CALayer]()
    private var sessions = [SessionItem]()
    public var filledColor:NSColor = NSColor.hex("#ff8326")
    private var popupView = TrianleView.createFromNib()!
    weak var delegate:TodayProgressViewDelegate?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.configView()
        
        popupView.alphaValue = 0
        self.addSubview(popupView)
        
        let todayArea = NSTrackingArea.init(rect: sessionView.bounds,
                                        options: [.mouseEnteredAndExited, .mouseMoved, .activeAlways],
                                        owner: self,
                                        userInfo: nil)
        sessionView.addTrackingArea(todayArea)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sessionView.wantsLayer = true
        self.wantsLayer = true
       
    }
    
    override func mouseMoved(with event: NSEvent) {
        let p = (self.window?.contentView?.convert(event.locationInWindow, to: sessionView))!
        if self.frame.contains(p) {
            self.showPopup(point: p)
        }
    }
    
    override func mouseExited(with event: NSEvent) {
//        self.hidePopup()
        self.delegate?.hidePopupView()
    }
    
    func setSessions(sessions:[SessionItem]){
        self.clearSessions()
        self.sessions = sessions
        let h:CGFloat = self.sessionView.bounds.height - 6
//        print(self.sessionView.bounds)
        sessions.forEach { (session) in
            let layer: CALayer = CALayer()
            var (xx,ww) = convertDateToLine(width: self.sessionView.bounds.width - 6, session: session)
            ww = ww < 0.1 ? 1 : ww
            layer.frame = NSRect(x: 3 + xx, y: 3, width: ww, height: h)
            layer.cornerRadius = 14.0
            layer.masksToBounds = true
            layer.backgroundColor = filledColor.cgColor
            
            let textLayer: CATextLayer = CATextLayer()
            textLayer.string = ""
            textLayer.frame = NSRect(x: 0, y: h / 2.0 - 18.0 / 2.0, width: ww, height: 18.0)
            if let f = CGFont("SFProDisplay-Medium" as CFString) {
                textLayer.font = f
            }
            textLayer.fontSize = 12.0
            textLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 1.0 //UIScreen.main.scale // setRasterizationScale
            let (hour, min, _) = session.period?.intervalAsList() ?? (0,0,0)
            if ww > 50 {
                if hour > 0 {
                    textLayer.string = "\(hour)\("hr".localized()) \(min)" + "min".localized()
                }else{
                    textLayer.string = "\(min)" + "min".localized()
                }
            }
            if ww < 35 {
                layer.cornerRadius = 4.0
//                textLayer.cornerRadius = 4.0
            }
            textLayer.alignmentMode = .center
            textLayer.foregroundColor = NSColor.white.cgColor
            textLayer.backgroundColor = NSColor.clear.cgColor
            
            let startTimeLayer: CATextLayer = CATextLayer()
            let y:CGFloat = self.bounds.size.height - 25
            startTimeLayer.frame = NSRect(x: self.sessionView.frame.origin.x + xx, y:  y , width: 35, height: 18.0)
            if let f = CGFont("SFProDisplay-Regular" as CFString) {
                startTimeLayer.font = f
            }
            startTimeLayer.fontSize = 12.0
            startTimeLayer.string = session.startDate.toString(format: "HH:mm")
            startTimeLayer.alignmentMode = .left
            startTimeLayer.foregroundColor = NSColor.black.cgColor
            startTimeLayer.backgroundColor = NSColor.clear.cgColor
            startTimeLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 1.0
//            print(ww)
            
            layer.addSublayer(textLayer)
            
            self.sessionView.layer?.addSublayer(layer)
            sessionLayers.append(layer)
            
            if !detectContaine(p: NSPoint(x: self.sessionView.frame.origin.x + xx+2, y: y+2)) {
                self.layer?.addSublayer(startTimeLayer)
                sessionLayers.append(startTimeLayer)
            }
        }
        
        popupView.removeFromSuperview()
        self.addSubview(popupView)
        
    }
    
    func showPopup(point:NSPoint){
//        print(point)
        popupView.alphaValue = 0
        let layers = self.sessionView.layer?.sublayers ?? []
        for (i, layer) in layers.enumerated() {
            layer.backgroundColor = filledColor.cgColor
            if layer.frame.contains(point) {
                layer.backgroundColor = NSColor.black.cgColor
//                print(layer.frame)
                let session = self.sessions[i]
                self.delegate?.showPopupView(session: session, point:point)

//                if let d = session.startDate, let period = session.period  {
//                   popupView.timeLabel.stringValue = d.toString(format: "HH:mm") + " - " + d.addingTimeInterval(period).toString(format: "HH:mm")
//                }
//                NSAnimationContext.runAnimationGroup { (_) in
//                    NSAnimationContext.current.duration = 1.0
//                    popupView.alphaValue = 1
//                }
//                popupView.frame = NSRect(x: layer.frame.origin.x + layer.frame.width / 2.0 - popupView.frame.width / 2.0, y: self.sessionView.frame.origin.y + self.sessionView.frame.height, width: 102, height: 31)
                break
            }
        }
    }
    
    func hidePopup(){
        popupView.alphaValue = 0
        let layers = self.sessionView.layer?.sublayers ?? []
        for (_, layer) in layers.enumerated() {
            layer.backgroundColor = filledColor.cgColor
        }
    }
    
    private func detectContaine(p:NSPoint)->Bool{
        
        var b = false
        
        for i in 0..<sessionLayers.count {
            let la = sessionLayers[i]
            if la.frame.contains(p){
                b = true
                break
            }
        }
        
        
        return b
    }
    
    private func configView(){
        sessionView.wantsLayer = true
        sessionView.layer?.cornerRadius = 14.0
        sessionView.layer?.masksToBounds = true
        sessionView.layer?.backgroundColor = NSColor.hex("#e8edf6").cgColor
    }
    
    private func clearSessions(){
        sessionLayers.forEach { (la) in
            la.removeFromSuperlayer()
        }
        sessionLayers.removeAll()

    }
    
}
