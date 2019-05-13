//
//  QuotesViewController.swift
//  UserActivity
//
//  Created by RoboApps on 3/4/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Cocoa

class QuotesViewController: NSViewController {
    
    @IBOutlet weak var dailyStatsLabel: NSTextField!
    @IBOutlet weak var userImage: NSImageView!
    @IBOutlet weak var userNameField: NSTextField!
    @IBOutlet weak var userStatusField: NSTextField!
    
    @IBOutlet weak var circleStatsBox: NSView!
//    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var allDataBtn: NSButton!
    @IBOutlet weak var sessionsCount: NSTextField!
    @IBOutlet weak var sessionsTimelabel: NSTextField!
    @IBOutlet weak var longestSessionsTimelabel: NSTextField!
    
    var progressRing: CircleView!
    var count: CGFloat = 0
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.hex("#f5f6fa").cgColor
        
        self.dailyStatsLabel.stringValue = "Daily Stats".localized()
        
        progressRing = CircleView(frame: self.circleStatsBox.bounds, innerTrackColor: NSColor.hex("#426eff"), lineWidth: 15)
        self.circleStatsBox.wantsLayer = true
        self.circleStatsBox.layer?.addSublayer(progressRing)
        
        self.allDataBtn.isBordered = false
        self.allDataBtn.wantsLayer = true
        self.allDataBtn.layer?.cornerRadius = 14.0
        self.allDataBtn.layer?.borderWidth = 1
        self.allDataBtn.layer?.borderColor = NSColor.hex("#202947").cgColor
        self.allDataBtn.layer?.masksToBounds = true
        self.allDataBtn.layer?.backgroundColor = NSColor.hex("#f5f6fa").cgColor
        self.allDataBtn.cell?.backgroundStyle = NSView.BackgroundStyle.dark
        (self.allDataBtn.cell as! NSButtonCell).isBordered = false
        (self.allDataBtn.cell as! NSButtonCell).backgroundColor=NSColor.clear
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        self.allDataBtn.attributedTitle = NSMutableAttributedString(string: "All sessions".localized(),
                                                                    attributes: [NSAttributedString.Key.foregroundColor: NSColor.hex("#202947"),
                                                                                 NSAttributedString.Key.paragraphStyle: paragraphStyle,
                                                                                 NSAttributedString.Key.font: NSFont(name: "SFProDisplay-Regular", size: 14.0)!])
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: NSNotification.Name(rawValue: "DatabaseHasChanged"), object: nil)

    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.configViews()
    }
    
    @objc func updateView(){
        print("QuotesViewController updateView")
        configViews()
    }
    
    func configViews(){
        
        self.userImage.image = getUserImage()
        self.userImage.wantsLayer = true
        self.userImage.layer?.cornerRadius = self.userImage.frame.width / 2
        self.userImage.layer?.masksToBounds = true
        
        self.userNameField.stringValue = NSFullUserName()

        let todayPeriod = Period.todayPeriod()
        var sessions = RouterDB().getSessions(period: todayPeriod)
        if let sess = createCurrentSession(period: todayPeriod) {
            sessions.append(sess)
        }
        
        if sessions.count == 0 {return}
        
        progressRing.setSessions(sessions: sessions)
        
        var allTime:TimeInterval = 0
        for session in sessions {
            allTime += session.period ?? 0
        }
        
        let maxPeriod = maxPerid(sessions: sessions)
        
        let (h,m,_) = maxPeriod.intervalAsList()
        if h > 0 {
            longestSessionsTimelabel.stringValue = "Longest session".localized() + String(format: " %0.2d",h) + "h".localized() + String(format: " %0.2d",m) + "m".localized()
        }else{
            longestSessionsTimelabel.stringValue = "Longest session".localized() + String(format: " %0.2d",m) + "m".localized()
        }
        let curses = sessions.count > 1 ? sessions[sessions.count-2] : sessions[0]
        userStatusField.stringValue = "last log in".localized() + " " + curses.start_time.toString(format: "HH:mm")
        userStatusField.textColor = NSColor.hex("#3FC875")
    }
    
    @IBAction func allDataAction(_ sender: Any) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.showMainWindow()
    }
    
}


extension QuotesViewController {
    static func freshController() -> QuotesViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: "QuotesViewController") as? QuotesViewController else {
            fatalError("Why cant i find QuotesViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
