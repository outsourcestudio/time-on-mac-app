//
//  AboutViewController.swift
//  TimeMatters
//
//  Created by RoboApps on 4/1/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {

    @IBOutlet weak var versionLabel: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.hex("#ff8326").cgColor
        
        if let d = Bundle.main.infoDictionary, let vers = d["CFBundleShortVersionString"] as? String {
            self.versionLabel.stringValue = "Version".localized() + " " + vers
        }
    }
    
    override func viewDidAppear() {
        self.view.window?.title = ""
    }
}
