//
//  DetailPopupInfoView.swift
//  TimeMatters
//
//  Created by toxa on 6/24/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Cocoa

class DetailPopupInfoView: NSView, NibLoadable {

    @IBOutlet weak var appName: NSTextField!
    @IBOutlet weak var appTime: NSTextField!
    @IBOutlet weak var appIcon: NSImageView!
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
//        print("draw")
        
//        self.wantsLayer = true
//        self.layer?.backgroundColor = NSColor.red.cgColor
        
//        appIcon.wantsLayer = true
//        appIcon.layer?.masksToBounds = true
//        appIcon.layer?.cornerRadius = appIcon.bounds.width / 2.0
//        appIcon.layer?.backgroundColor = NSColor.init(white: 1, alpha: 0.3).cgColor
    }
    
}
