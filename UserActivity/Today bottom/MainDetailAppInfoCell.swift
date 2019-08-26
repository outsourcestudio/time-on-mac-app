//
//  MainDetailAppInfoCell.swift
//  TimeMatters
//
//  Created by toxa on 6/30/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Cocoa

class MainDetailAppInfoCell: NSView, NibLoadable {

    @IBOutlet weak var progressWidth: NSLayoutConstraint!
    @IBOutlet weak var percentLabel: NSTextField!
    @IBOutlet weak var progress: NSView!
    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var image: NSImageView!
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        progress.wantsLayer = true
        progress.layer?.backgroundColor = NSColor.white.cgColor
        progress.layer?.cornerRadius = 2.0
    }
    
}
