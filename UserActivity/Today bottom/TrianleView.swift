
//
//  TrianleView.swift
//  UserActivity
//
//  Created by RoboApps on 3/26/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Cocoa

class TrianleView: NSView, NibLoadable {

    @IBOutlet weak var triView: NSView!
    @IBOutlet weak var timeLabel: NSTextField!
    let shapeLayer = CAShapeLayer()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        timeLabel.wantsLayer = true
        timeLabel.layer?.cornerRadius = 12.0
        
        let view = TriView()
        view.frame = triView.bounds
        
        triView.addSubview(view)
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
        NSColor.black.setFill()
        bezierPath.fill()
        
        // Mask to Path
        
        shapeLayer.path = bezierPath.cgPath
        self.layer!.mask = shapeLayer
        
    }
    
}
