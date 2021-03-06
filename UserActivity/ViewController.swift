//
//  ViewController.swift
//  UserActivity
//
//  Created by RoboApps on 3/1/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Cocoa
import LaunchAtLogin
import RealmSwift

class ViewController: NSViewController, NSWindowDelegate {
    
    let windowSize = NSSize(width: 1190, height: 651)
    
    @IBOutlet weak var todayLabel: NSTextField!
    @IBOutlet weak var profileImage: NSImageView!
    @IBOutlet weak var profileBox: NSView!
    @IBOutlet weak var todayBox: NSView!
    var todayView:TodayProgressView!
    
    @IBOutlet weak var selectSubInfoField: NSTextField!
    @IBOutlet weak var selectInfoField: NSTextField!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var prevButton: NSButton!
    @IBOutlet weak var label00: NSTextField!
    @IBOutlet weak var label24: NSTextField!
    @IBOutlet weak var switcherBox: NSView!
    
    @IBOutlet weak var rightScrollView: NSScrollView!
    @IBOutlet weak var rightView: NSView!
    @IBOutlet weak var topHeightMonth: NSLayoutConstraint!
    private var popupView = TrianleView.createFromNib()!
    @IBOutlet weak var contentClipView: NSClipView!
    @IBOutlet weak var contentView: NSScrollView!
//    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var total_time: NSTextField!
    @IBOutlet weak var total_sessions: NSTextField!
    @IBOutlet weak var longest_session_time: NSTextField!
    @IBOutlet weak var rightAppTotalLabel: NSTextField!
    var dayView:DayView?
    var weekView = [DayView]()
    var monthView = [DayView]()
    var yearView = [MonthView]()
    var selectedFilter:SwitcherType = .week
    var weekMove:Int = 0
    var monthMove:Int = 0
    var yearMove:Int = 0
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController viewDidLoad")
        
        rightView.wantsLayer = true
        rightView.layer?.backgroundColor = NSColor.hex("#51586E").cgColor
        
        // config main view
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        view.window?.acceptsMouseMovedEvents = true
        
        // config profile image
        self.profileImage.image = getUserImage()
        self.profileImage.wantsLayer = true
        self.profileImage.layer?.cornerRadius = self.profileImage.frame.width / 2
        self.profileImage.layer?.masksToBounds = true
        
        self.profileBox.wantsLayer = true
        self.profileBox.layer?.borderWidth = 2.0
        self.profileBox.layer?.borderColor = NSColor.hex("#3fc875").cgColor
        self.profileBox.layer?.cornerRadius = self.profileBox.frame.width / 2
        self.profileBox.layer?.masksToBounds = true
        
        todayLabel.stringValue = "TODAY".localized()
        
        
        todayView = TodayProgressView.createFromNib()!
        todayView.delegate = self
        todayView.frame.size = self.todayBox.frame.size
        self.todayBox.addSubview(todayView)
        
        
        //config switcher buttons
        let switcherButtons = ButtonSwitcher(frame: switcherBox.bounds, titles: ["Year".localized(), "Month".localized(), "Week".localized()], bgColor: NSColor.hex("#f5f6fa"), selectedColor: NSColor.hex("#a5adc6"))
        switcherButtons.didClick { (index) in
            self.selectedFilter = SwitcherType(rawValue: index)!
            self.changeStatsView()
        }
        self.switcherBox.wantsLayer = true
        self.switcherBox.addSubview(switcherButtons)
        self.selectedFilter = .week
        switcherButtons.selectButton(index: self.selectedFilter.rawValue)
        self.changeStatsView()
        self.updateNextPrevButtons()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateInsight(_:)), name: NSNotification.Name(rawValue: "DatabaseHasChanged"), object: nil)
        
//        setCurrentDate()
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        if !appDelegate.mainDB.loading == true {
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name("DatabaseHasChanged"), object: nil)
        }
        setDocIconVisibility(state: true)
        
        prevButton.wantsLayer = true
        prevButton.layer?.cornerRadius = 8.0
        nextButton.wantsLayer = true
        nextButton.layer?.cornerRadius = 8.0
        
        var area = NSTrackingArea.init(rect: prevButton.bounds,
                                       options: [.mouseEnteredAndExited, .activeAlways],
                                       owner: self,
                                       userInfo: nil)
        prevButton.addTrackingArea(area)
        
        area = NSTrackingArea.init(rect: nextButton.bounds,
                                   options: [.mouseEnteredAndExited, .activeAlways],
                                   owner: self,
                                   userInfo: nil)
        nextButton.addTrackingArea(area)

        
        self.view.addSubview(popupView)
        popupView.alphaValue = 0
    }
    
    override func viewDidAppear() {
        view.window?.delegate = self
        self.view.window?.title = ""
        
        var frame = self.view.window?.frame
        let initialSize = windowSize
        frame?.size = initialSize
        self.view.window?.setFrame(frame!, display: true)
        self.configTodayView()
        showLaunchAtStartAlert()
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
//        print("mouseEntered")
        let p = (self.view.window?.contentView?.convert(event.locationInWindow, to: self.view))!
        if prevButton.frame.contains(p) {
            prevButton.image = NSImage(imageLiteralResourceName: "prevIcon_s")
        }else{
            prevButton.image = NSImage(imageLiteralResourceName: "prevIcon")
        }
        
        if nextButton.frame.contains(p) && nextButton.isEnabled {
            nextButton.image = NSImage(imageLiteralResourceName: "nextIcon_s")
        }else{
            nextButton.image = NSImage(imageLiteralResourceName: "nextIcon")
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
//        print("mouseExited")
//        let p = (self.view.window?.contentView?.convert(event.locationInWindow, to: self.view))!
//        if prevButton.frame.contains(p) {
//            prevButton.image = NSImage(imageLiteralResourceName: "nextIcon_s")
//        }else{
//            prevButton.image = NSImage(imageLiteralResourceName: "prevIcon")
//        }
//        
//        if nextButton.frame.contains(p) && nextButton.isEnabled {
//            nextButton.image = NSImage(imageLiteralResourceName: "nextIcon_s")
//        }else{
//            nextButton.image = NSImage(imageLiteralResourceName: "nextIcon")
//        }
        nextButton.image = NSImage(imageLiteralResourceName: "nextIcon")
        prevButton.image = NSImage(imageLiteralResourceName: "prevIcon")
    }
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
//        print("mouseMoved")
        let p = (self.view.window?.contentView?.convert(event.locationInWindow, to: self.contentClipView))!
        searchAndShowPpopupViews(point: p,event: event)
    }
    
    func configRightAppsPanel(appSessions:[SessionItem]){
        let realm = try! Realm()
        var allSessionsPeriod:TimeInterval = 0
        appSessions.forEach { (s) in
            allSessionsPeriod += s.endDate!.timeIntervalSince(s.startDate)
        }
        var allAppsCounts:TimeInterval = 0
        var allApps = [String : TimeInterval]()
        appSessions.forEach { (s) in
            allAppsCounts += s.allAppsCounts()
            s.apps.forEach({ (a) in
                if allApps[a.appID] != nil {
                    allApps[a.appID] = allApps[a.appID]! + a.count
                }else{
                    allApps[a.appID] = a.count
                }
            })
        }
        let sorted = allApps.sorted { $0.1 < $1.1 }
        
//        print("appSessions ", allSessionsPeriod)
//        print("allApps ", allApps)

        
//        sorted.forEach { (k,v) in
//            print(k, v)
//        }
        
        let x:CGFloat = 10
        var y:CGFloat = 0
        let w:CGFloat = self.rightView.bounds.width - x * 2.0
        let h:CGFloat = 56
        let sp:CGFloat = 10
        var hh:CGFloat = CGFloat(sorted.count) * h + (CGFloat(sorted.count - 1) * sp)
        
        if hh < self.rightScrollView.frame.height {
            y = self.rightScrollView.frame.height - hh
            hh = self.rightScrollView.frame.height
        }

        let docView = NSClipView()
        docView.frame = NSRect(x: 0, y: 0, width: self.rightScrollView.frame.width, height: hh)
        docView.backgroundColor = NSColor.clear
        docView.drawsBackground = true
        docView.wantsLayer = true
        
        sorted.forEach { (k,val) in
            if let item = realm.objects(AppInfoItem.self).filter("appID == '\(k)'").first {
//                let valKoef = TimeInterval(val)// / AppManager.activityAppTimerPeriod
                let pers = TimeInterval(val) / allAppsCounts * 100
                let v = MainDetailAppInfoCell.createFromNib()!
                v.nameLabel.stringValue = (item.appName ?? "")// + " \(val)"
                v.percentLabel.stringValue = "\(Int(pers)) %"
                v.progressWidth.constant = v.progressWidth.constant * CGFloat(pers / 100.0)
                if let urlStr = item.appIcon, let url = URL(string: urlStr), let image = NSImage(contentsOf: url) {
                    v.image.image = image
                }
                let (hh,mm,ss) = TimeInterval(allSessionsPeriod * pers / 100.0).intervalAsList()
                if hh > 0 {
                    v.timeLabel.stringValue = String(format: "%0.2d",hh) + "hr".localized()  + " " + String(format: "%0.2d",mm) + "m".localized()
                }else if hh == 0 && mm == 0 && ss > 0{
                    v.timeLabel.stringValue = String(format: "%0.2d",ss) + "s".localized()
                }else{
                    v.timeLabel.stringValue = String(format: "%0.2d",mm) + "m".localized()
                }
                v.wantsLayer = true
//                v.layer?.backgroundColor = NSColor.red.cgColor
//                v.layer?.borderWidth = 0.5
                v.frame = NSRect(x: x, y: y, width: w, height: h)
                y += h + sp
                docView.addSubview(v)
            }
        }
        self.rightScrollView.documentView = docView
        self.rightScrollView.contentView.scroll(CGPoint(x: 0, y: hh))
        self.rightScrollView.wantsLayer = true
        
    }
    
    func showLaunchAtStartAlert(){
        
        if UserDefaults.standard.object(forKey: "LaunchAtStartAlertShowed") != nil  {
            return
        }
        
        let appdel = NSApp.delegate as! AppDelegate
        
        delay(1.0) {
            let alert = NSAlert()
            alert.messageText = "Launch TimeMatters at Login?".localized()
            alert.informativeText = "Press «Yes» to start the app automatically when you turn your computer on.".localized()
            alert.alertStyle = NSAlert.Style.warning
            alert.addButton(withTitle: "Yes".localized())
            alert.addButton(withTitle: "No".localized())
            let result = alert.runModal()
            
            if result == NSApplication.ModalResponse.alertFirstButtonReturn {
                LaunchAtLogin.isEnabled = true
                appdel.launchMenuItem.state = .on
                UserDefaults.standard.set("LaunchAtStartAlertShowed", forKey: "LaunchAtStartAlertShowed")
            }else{
                LaunchAtLogin.isEnabled = false
                appdel.launchMenuItem.state = .off
                UserDefaults.standard.set("LaunchAtStartAlertShowed", forKey: "LaunchAtStartAlertShowed")
//                self.showLaunchAtStartAlert2()
            }
        }
        
    }
    
    func showLaunchAtStartAlert2(){
        delay(1.0) {
            let alert = NSAlert()
            alert.messageText = "Launch At Launch2 Message".localized()
            alert.informativeText = "Launch At Launch2 Title".localized()
            alert.alertStyle = NSAlert.Style.informational
            alert.addButton(withTitle: "OK".localized())
            alert.runModal()
        }
    }
    
    func searchAndShowPpopupViews(point:NSPoint, event:NSEvent){
//        popupView.frame = NSRect(x: 100, y: 200, width: 220, height: 250)
//        popupView.configView()
//        return;
        popupView.alphaValue = 0
        let pp = (self.view.window?.contentView?.convert(event.locationInWindow, to: nil))!
        self.contentClipView.subviews.forEach { (view) in
            view.subviews.forEach({ (childView) in
                if childView.frame.contains(point) {
                    if childView is DayView {
                        let sessionsView = (childView as! DayView).sessionView!
                        let layers = (childView as! DayView).sessionLayers
                        let p = view.convert(point, to: sessionsView)
                        for (i, layer) in layers.enumerated() {
                            layer.backgroundColor = NSColor.hex("#5063ff").cgColor
                            if layer.frame.contains(p) {
                                popupView.frame = NSRect(x: pp.x - 50.0, y: pp.y + 5.0, width: 202, height: 101)
                                popupView.alphaValue = 1
                                layer.backgroundColor = NSColor.black.cgColor
                                let session = (childView as! DayView).sessions[i]
                                let c = session.apps.count > 3 ? 3 : session.apps.count
                                popupView.frame = NSRect(x: pp.x - 100.0, y: pp.y + 5.0, width: 202, height: 54 + 40 + CGFloat(c * 35) + CGFloat((c - 1) * 10))
                                popupView.configView(session: session, rowCount: 3)
                            }
                        }
                    }else if childView is MonthView {
                        return;
                        let monthView = (childView as! MonthView)
                        //                    print("MonthView")
                        let sessionsView = monthView.sessionView!
                        let layers = monthView.sessionLayers
                        let byDays = monthView.sessionsByDays()
                        let byDays2 = monthView.sessionsByDays2()
                        let p = view.convert(point, to: sessionsView)
                        for (i, layer) in layers.enumerated() {
                            if byDays[i+1] != nil {
                                layer.backgroundColor = monthView.getColor2(interval: byDays[i+1]!).cgColor
                            }else{
                                layer.backgroundColor = NSColor.hex("#E8EDF6").cgColor
                            }
                            if layer.frame.contains(p) && byDays[i+1] != nil {
                                popupView.frame = NSRect(x: pp.x - 50.0, y: pp.y + 5.0, width: 102, height: 31)
                                popupView.alphaValue = 1
                                layer.backgroundColor = NSColor.black.cgColor
                                let (h,m,_) = byDays[i+1]!.intervalAsList()
                                if h > 0 {
                                    popupView.timeLabel.stringValue = String(format: "%0.2d",h) + "h".localized()  + " " + String(format: "%0.2d",m) + "m".localized()
                                }else{
                                    popupView.timeLabel.stringValue = String(format: "%0.2d",m) + "m".localized()
                                }
                            }
                        }
                    }
                }
            })
        }
    }

    func configTodayView(){
        
        todayView.frame.size = self.todayBox.frame.size
        
        delay(0.1) {
            let period = Period.todayPeriod()
            let sess = AppManager.shared.getSessionList(period: period)
//            var sessions = RouterDB().getSessions(period: period)
//            if let sess = createCurrentSession(period: period) {
//                sessions.append(sess)
//            }
            self.todayView.setSessions(sessions: sess)
        }
    }
    
    
    
    func windowDidEndLiveResize(_ notification: Notification) {
        changeStatsView()
        configTodayView()
    }
    
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        let minimumSize = windowSize//NSSize(width: 100, height: 100)
        var newSize = NSSize()
        if(frameSize.width < minimumSize.width) {
            newSize.width = minimumSize.width
        } else {
            newSize.width = frameSize.width
        }
        if(frameSize.height < minimumSize.height) {
            newSize.height = minimumSize.height
        } else {
            newSize.height = frameSize.height
        }
        return newSize
    }
    
    func changeStatsView(){

        switch selectedFilter {
        case .year:
            self.yearAction(nil)
        case .month:
            self.monthAction(nil)
        case .week:
            self.weekAction(nil)
        default:
            print("default")
        }
        
        topHeightMonth.constant = selectedFilter == .year ? 11.0 : 1.0
        
        label00.isHidden = selectedFilter == .year ? true : false
        label24.isHidden = selectedFilter == .year ? true : false
        updateNextPrevButtons()
    }
    
    func updateSummedValues(period:Period){
        
//        var sessions = RouterDB().getSessions(period: period)
//        if Period.ifTodayInPeriod(period: period) {
//            if let sess = createCurrentSession(period: period) {
//                sessions.append(sess)
//            }
//        }
        
        let sess = AppManager.shared.getSessionList(period: period)
        
        if sess.count == 1 {
            total_sessions.stringValue = "1 " + "session".localized()
        }else{
            total_sessions.stringValue = "\(sess.count) " + "sessions".localized()
        }
        
        var allTime:TimeInterval = 0
        for session in sess {
            allTime += session.period ?? 0
        }
        
        var (h,m,_) = allTime.intervalAsList()
        total_time.stringValue = String(format: "%0.2d ",h) + "hours".localized() + " " + String(format: "%0.2d ",m) + "min".localized()
        m = (m == 0 && h == 0 && sess.count != 0) ? 1 : m
        rightAppTotalLabel.stringValue = "Total " + String(format: "%0.2d ",h) + "hours".localized() + " " + String(format: "%0.2d ",m) + "min".localized()
        
        (h,m,_) = maxPerid(sessions: sess).intervalAsList()
        longest_session_time.stringValue = String(format: "%0.2d",h) + "h".localized() + " " + String(format: "%0.2d",m) + "m".localized() + " " + "longest".localized()
        
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.mainWindowController = nil
        setDocIconVisibility(state: false)
    }
    
    func updateNextPrevButtons(){
        switch selectedFilter {
        case .year:
            nextButton.isEnabled = yearMove > 0 ? true : false
        case .month:
            nextButton.isEnabled = monthMove > 0 ? true : false
        case .week:
            nextButton.isEnabled = weekMove > 0 ? true : false
        default:
            print("default")
        }
    }
    
    @IBAction func prevAction(_ sender: Any) {
        switch selectedFilter {
        case .year:
            yearMove += 1
        case .month:
            monthMove += 1
        case .week:
            weekMove += 1
        default:
            print("default")
        }
        changeStatsView()
    }
    
    @IBAction func nextAction(_ sender: NSButton) {
        switch selectedFilter {
        case .year:
            yearMove -= 1
        case .month:
            monthMove -= 1
        case .week:
            weekMove -= 1
        default:
            print("default")
        }
        changeStatsView()
    }
    
    @IBAction func yearAction(_ sender: Any?) {
        selectedFilter = .year
        self.clearViews()
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        if appDelegate.mainDB.loading == true{return}
        
        let yearDays = Period.yearPeriods(fromDate: Date(), byAdding: yearMove)
        let bh:CGFloat = 15//self.contentView.bounds.height / 21
        let size = NSSize(width: self.contentView.bounds.width, height: bh * 2.0)
        var y:CGFloat = 0
        let h = max(CGFloat(yearDays.count*39 + 7), self.contentView.bounds.height)
        
        let view = NSClipView()
        view.frame = NSRect(x: 0, y: 0, width: self.contentView.bounds.width, height: h)
        view.backgroundColor = NSColor.clear
        view.drawsBackground = true
        view.wantsLayer = true
//        view.layer?.borderWidth = 1
        
        let area = NSTrackingArea.init(rect: view.bounds,
                                       options: [.mouseMoved, .activeAlways],
                                       owner: self,
                                       userInfo: nil)
        view.addTrackingArea(area)
        
        y = bh
//        if yearDays.count < 7 {
//            y = CGFloat(7 - yearDays.count) * (bh + size.height) + bh
//        }
        if self.contentView.bounds.height > CGFloat(yearDays.count*39+7){
            y = (self.contentView.bounds.height - CGFloat(yearDays.count*39+7))/2.0
        }
        
        var appSessions = [SessionItem]()
        
        yearDays.forEach { (period) in
            let month = MonthView.createFromNib()!
            month.frame = NSRect(x: 0, y: y, width: size.width, height: month.frame.size.height)
            month.wantsLayer = true
//            month.layer?.borderWidth = 1
            view.addSubview(month)
            
//            var sessions = RouterDB().getSessions(period: period)
//            if Period.ifTodayInPeriod(period: period) {
//                if let sess = createCurrentSession(period: period) {
//                    sessions.append(sess)
//                }
//            }
            
            let sess = AppManager.shared.getSessionList(period: period)
            appSessions.append(contentsOf: sess)
            
            
            month.setCurrentMonthDays(date: period.startDate)
            month.setSessions(sessions: sess)
            y += 39
            self.yearView.append(month)
        }
        self.contentView.documentView = view
        self.contentView.contentView.scroll(CGPoint(x: 0, y: h))
        
        let period = Period(start: yearDays.last!.startDate, end: yearDays.first!.endDate)
        updateSummedValues(period: period)
        configRightAppsPanel(appSessions: appSessions)
        
        //config selector stat
        selectSubInfoField.stringValue = ""
        selectInfoField.stringValue = yearDays.last!.startDate.toString(format: "yyyy")
        
    }
    
    @IBAction func monthAction(_ sender: Any?) {
        selectedFilter = .month
        self.clearViews()
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        if appDelegate.mainDB.loading == true{return}
        
        var monthDays = Period.monthPeriods(fromDate: Date(), byAdding: monthMove)
        let bh:CGFloat = 15//self.contentView.bounds.height / 21
        let size = NSSize(width: self.contentView.bounds.width, height: bh * 2.0)
        var y:CGFloat = 0
        let h = max(CGFloat(monthDays.count * 44 + 7), self.contentView.bounds.height)
        
        let view = NSClipView()
        view.frame = NSRect(x: 0, y: 0, width: self.contentView.bounds.width, height: h)
        view.backgroundColor = NSColor.clear
        view.drawsBackground = true
        view.wantsLayer = true
//        view.layer?.borderWidth = 1
        
        let area = NSTrackingArea.init(rect: view.bounds,
                                       options: [.mouseMoved, .activeAlways],
                                       owner: self,
                                       userInfo: nil)
        view.addTrackingArea(area)
        
        y = bh
//        if monthDays.count < 7 {
//            y = CGFloat(7 - monthDays.count) * (bh + size.height) + bh
//        }
        if self.contentView.bounds.height > CGFloat(monthDays.count*44){
            y = (self.contentView.bounds.height - CGFloat(monthDays.count*44))/2.0
        }
        
        var appSessions = [SessionItem]()
        
        monthDays.forEach { (period) in
            let day = DayView.createFromNib()!
            day.frame = NSRect(x: 0, y: y, width: size.width, height: day.frame.size.height)
            day.wantsLayer = true
//            day.layer?.borderWidth = 1
            
            view.addSubview(day)
            
            let sess = AppManager.shared.getSessionList(period: period)
            appSessions.append(contentsOf: sess)
            
//            var sessions = RouterDB().getSessions(period: period)
//            if Period.ifTodayInPeriod(period: period) {
//                if let sess = createCurrentSession(period: period) {
//                    sessions.append(sess)
//                }
//            }
            day.setSessions(sessions: sess)
            day.dayDateLabel.stringValue = period.startDate.toString(format: "MMM, d").capitalized
            y += 44
            self.monthView.append(day)
        }
        self.contentView.documentView = view
        self.contentView.contentView.scroll(CGPoint(x: 0, y: h))
        self.contentView.wantsLayer = true
//        self.contentView.layer?.borderWidth = 1
        
        let period = Period(start: monthDays.last!.startDate, end: monthDays.first!.endDate)
        updateSummedValues(period: period)
        configRightAppsPanel(appSessions: appSessions)
        
        //config selector stat
        selectSubInfoField.stringValue = monthDays.last!.startDate.toString(format: "yyyy").capitalized
        selectInfoField.stringValue = monthDays.last!.startDate.toString(format: "MMMM").capitalized
        
    }
    
    @IBAction func weekAction(_ sender: Any?) {
        selectedFilter = .week
        self.clearViews()
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        if appDelegate.mainDB.loading == true{return}
        
        let weekDays = Period.weekPeriods(fromDate: Date(), byAdding: weekMove)
        let bh:CGFloat = 15//self.contentView.bounds.height / 21
        let size = NSSize(width: self.contentView.bounds.width, height: bh * 2)
        var y:CGFloat = 0
        let h = max(CGFloat(weekDays.count) * (size.height + CGFloat(bh)), self.contentView.bounds.height)
//        let h1:CGFloat = CGFloat(weekDays.count) * (size.height + CGFloat(bh))
        let view = NSClipView()
        view.frame = NSRect(x: 0, y: 0, width: self.contentView.bounds.width, height: h)
        view.backgroundColor = NSColor.clear
        view.drawsBackground = true
        view.wantsLayer = true
//        view.layer?.borderWidth = 1
        
        let area = NSTrackingArea.init(rect: view.bounds,
                                   options: [.mouseMoved, .activeAlways],
                                   owner: self,
                                   userInfo: nil)
        view.addTrackingArea(area)

        y = bh
//        let dsadsa=self.contentView.bounds.height
        if self.contentView.bounds.height > 315{
            y = (self.contentView.bounds.height - CGFloat(weekDays.count) * (size.height + CGFloat(bh)))/2.0
        }
        
        var appSessions = [SessionItem]()
        
        weekDays.forEach { (period) in
            let day = DayView.createFromNib()!
            day.frame = NSRect(x: 0, y: y, width: size.width, height: day.frame.size.height)//size.height
            day.wantsLayer = true
//            day.layer?.borderWidth = 1
            
            view.addSubview(day)
            
            let sess = AppManager.shared.getSessionList(period: period)
            appSessions.append(contentsOf: sess)
            
//            var sessions = RouterDB().getSessions(period: period)
//            if Period.ifTodayInPeriod(period: period) {
//                if let sess = createCurrentSession(period: period) {
//                    sessions.append(sess)
//                }
//            }
            day.setSessions(sessions: sess)
            day.dayDateLabel.stringValue = period.startDate.toString(format: "EEE, d").capitalized
            y += 44.0//bh + size.height
            self.weekView.append(day)
        }
        
        self.contentView.documentView = view
        self.contentView.contentView.scroll(CGPoint(x: 0, y: 0))
        self.contentView.wantsLayer = true
//        self.contentView.layer?.borderWidth = 1
//
        let period = Period(start: weekDays.last!.startDate, end: weekDays.first!.endDate)
        updateSummedValues(period: period)
        configRightAppsPanel(appSessions: appSessions)
        
        //config selector stat
        selectSubInfoField.stringValue = weekDays.last!.startDate.toString(format: "yyyy")
        selectInfoField.stringValue = weekDays.last!.startDate.toString(format: "MMM d").capitalized + " - " + weekDays.first!.startDate.toString(format: "MMM d").capitalized
    }
    
    
    
    private func clearViews(){
        dayView?.removeFromSuperview()
        //        dayView?.isHidden = true
        self.weekView.forEach({ (day) in
            day.removeFromSuperview()
        })
        self.monthView.forEach({ (day) in
            day.removeFromSuperview()
        })
        self.yearView.forEach({ (day) in
            day.removeFromSuperview()
        })
        self.weekView.removeAll()
        self.monthView.removeAll()
        self.yearView.removeAll()
    }
    
    @objc func updateInsight(_ sender: Notification) {
        
        NSAnimationContext.runAnimationGroup { (_) in
            NSAnimationContext.current.duration = 0.7
            self.changeStatsView()
            self.configTodayView()
        }

    }
    
    func formatEventDescription(event: Event) -> String {
        var reason = ""
        var switcher = ""
        switch event.reason {
        case .user:
            reason = "User"
        case .display:
            reason = "Sleep"
        case .screen:
            reason = "Screen Lock"
        }
        
        switch event.switcher {
        case .on:
            switcher = "on"
        case .off:
            switcher = "off"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
        return (reason + " " + switcher + " " + dateFormatter.string(from: event.event_time!))
    }
}

extension ViewController : TodayProgressViewDelegate {
    
    func hidePopupView() {
        popupView.alphaValue = 0
        let layers = self.todayView.sessionView.layer?.sublayers ?? []
        for (_, layer) in layers.enumerated() {
            layer.backgroundColor = NSColor.hex("#ff8326").cgColor
        }
    }
    
    func showPopupView(session: SessionItem, point: NSPoint) {
        let a = self.todayView.sessionView.layer?.sublayers ?? []
        let popupWidth:CGFloat = 200
        for (_, layer) in a.enumerated() {
            if layer.frame.contains(point) {
                var x = layer.frame.origin.x + self.todayView.sessionView.frame.origin.x + self.todayBox.frame.origin.x - ( popupWidth / 2 )
                x += layer.frame.size.width / 2 
                let y = self.todayBox.frame.midY + 50
                popupView.alphaValue = 1
                let c = session.apps.count > TrianleView.rows ? TrianleView.rows : session.apps.count
                popupView.frame = NSRect(x: x, y: y, width: popupWidth, height: 54 + 40 + CGFloat(c * 35) + CGFloat((c - 1) * 10))
                popupView.configView(session: session)
                
            }
        }
    }
    
}
