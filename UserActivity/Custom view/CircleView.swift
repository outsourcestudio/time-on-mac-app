//
//  CircleView.swift
//  UserActivity
//
//  Created by RoboApps on 3/16/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Cocoa


class CircleView: CALayer {
    
    private var sessions = [SessionItem]()
    private var sessionLayers = [CAShapeLayer]()
    var innerTrackColor: NSColor!
    var outerTrackColor: NSColor!
    var lineWidth:CGFloat = 5.0
    var centerPosition:CGPoint = .zero
    var radius:CGFloat = 0
    private var parentFrame:NSRect = .zero
    private var circularPath: NSBezierPath!
    private var innerTrackShapeLayer: CAShapeLayer!
    private var innerTrackShapeLayer2: CAShapeLayer!
    private var outerTrackShapeLayer: CAShapeLayer!
    private let rotateTransformation = CATransform3DMakeRotation(.pi / 2, 0, 0, 1)
    private var timeLabel: CATextLayer!
    private var sessionsLabel: CATextLayer!
    public var progress: CGFloat = 0
    
    public init(frame:NSRect, innerTrackColor: NSColor, lineWidth: CGFloat) {
        super.init()
        
        let position = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
        self.parentFrame = frame
        self.radius = (max(frame.width, frame.height) - 2 * lineWidth) / 2.0
        self.innerTrackColor = innerTrackColor
        self.lineWidth = lineWidth
        self.centerPosition = position
        
        circularPath = NSBezierPath()
        circularPath.appendArc(withCenter: .zero, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        outerTrackShapeLayer = CAShapeLayer()
        outerTrackShapeLayer.path = circularPath.cgPath
        outerTrackShapeLayer.position = position
        outerTrackShapeLayer.strokeColor = NSColor.white.cgColor
        outerTrackShapeLayer.fillColor = NSColor.clear.cgColor
        outerTrackShapeLayer.lineWidth = lineWidth
        outerTrackShapeLayer.strokeStart = 0
        outerTrackShapeLayer.strokeEnd = 1
        outerTrackShapeLayer.lineCap = CAShapeLayerLineCap.square
        outerTrackShapeLayer.transform = CATransform3DMakeRotation(.pi / 2, 0, 0, 1)
        addSublayer(outerTrackShapeLayer)

        var s:CGFloat = 40.0
        timeLabel = CATextLayer()
        let timeLabelFrame:NSRect = NSRect(x: 0, y: self.parentFrame.size.height / 2.0 - s / 2.0 + 10.0, width: self.parentFrame.size.width, height: s)
        timeLabel.frame = timeLabelFrame
        if let f = CGFont("SFProDisplay-Bold" as CFString) {
            timeLabel.font = f
        }
        timeLabel.fontSize = 32.0
        timeLabel.string = "00:00"
        timeLabel.alignmentMode = .center
        timeLabel.foregroundColor = NSColor.black.cgColor
        timeLabel.backgroundColor = NSColor.clear.cgColor
        timeLabel.contentsScale = NSScreen.main?.backingScaleFactor ?? 1.0
        addSublayer(timeLabel)
        
        s = 24
        sessionsLabel = CATextLayer()
        let sessionsLabelFrame:NSRect = NSRect(x: 0, y: timeLabelFrame.origin.y - s, width: self.parentFrame.size.width, height: s)
        sessionsLabel.frame = sessionsLabelFrame
        if let f = CGFont("SFProDisplay-Regular" as CFString) {
            sessionsLabel.font = f
        }
        sessionsLabel.fontSize = 16.0
        sessionsLabel.string = "1 session"
        sessionsLabel.alignmentMode = .center
        sessionsLabel.foregroundColor = NSColor.hex("#ff8326").cgColor
        sessionsLabel.backgroundColor = NSColor.clear.cgColor
        sessionsLabel.contentsScale = NSScreen.main?.backingScaleFactor ?? 1.0
        addSublayer(sessionsLabel)
        
    }
    
    func setSessions(sessions:[SessionItem]){
        clearSessions()
        self.sessions = sessions
        let seek:CGFloat = 0 //100 / 86400 * 20
        sessions.forEach { (session) in
            
            let circular = NSBezierPath()
            circular.appendArc(withCenter: .zero, radius: self.radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            var (x, w) = convertDateToLine(session: session)
            w = w < 0.01 ? 0.1 : w
            let start = x / 100.0
            let shapeLayer = CAShapeLayer()
            shapeLayer.strokeColor = self.innerTrackColor.cgColor
            shapeLayer.position = centerPosition
            shapeLayer.strokeStart = start
            shapeLayer.strokeEnd = start + w / 100.0 - seek
            shapeLayer.lineWidth = lineWidth
            shapeLayer.lineCap = CAShapeLayerLineCap.butt
            shapeLayer.fillColor = NSColor.clear.cgColor
            shapeLayer.path = circular.cgPath
            shapeLayer.transform = CATransform3DMakeRotation( .pi/2 , 0, 0, 1)
            addSublayer(shapeLayer)
            sessionLayers.append(shapeLayer)
        }
        
        if sessions.count == 1 {
            sessionsLabel.string = "1 " + "session".localized()
        }else{
           sessionsLabel.string = "\(sessions.count) " + "sessions".localized()
        }
        
        var allTime:TimeInterval = 0
        for session in sessions {
            allTime += session.period ?? 0
        }
        
        let (h,m,_) = allTime.intervalAsList()
        if h > 0 {
            timeLabel.string = String(format: "%0.2d:%0.2d",h,m)
        }else{
            timeLabel.string = String(format: "0:%0.2d",m)
        }
        if h == 0 && m == 0 {
            timeLabel.string = String(format: "0:01")
        }
        
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func clearSessions(){
        sessionLayers.forEach { (s) in
            s.removeFromSuperlayer()
        }
        sessionLayers.removeAll()

    }
    
    private func convertDateToLine(session:Session) -> (x:CGFloat, w:CGFloat) {
        let step:CGFloat = 100 / 86400
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
//                        print(finalX, finalWidth)
            return (finalX, finalWidth)
        }
        return (0,0)
    }
    
    private func convertDateToLine(session:SessionItem) -> (x:CGFloat, w:CGFloat) {
        let step:CGFloat = 100 / 86400
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
            //                        print(finalX, finalWidth)
            return (finalX, finalWidth)
        }
        return (0,0)
    }
    
}


public extension NSBezierPath {
    
    public var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            }
        }
        return path
    }
    
}
