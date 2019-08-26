//
//  AppDelegate.swift
//  UserActivity
//
//  Created by RoboApps on 3/1/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Cocoa
import RealmSwift
//import ServiceManagement
import LaunchAtLogin

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var launchMenuItem: NSMenuItem!
    @IBOutlet weak var menuTimeMatt: NSMenu!
    @IBOutlet weak var menuSubWindow: NSMenu!
    @IBOutlet weak var menuRefresh2: NSMenu!
    @IBOutlet weak var menuFile: NSMenuItem!
    @IBOutlet weak var menuWindows: NSMenuItem!
    @IBOutlet weak var menuHelp: NSMenuItem!
    
    @IBOutlet weak var subMenuHelp: NSMenu!
    let webSiteUrl = "http://roboapps.co/timematters/"
    
    var aboutVC: NSWindowController?
    var mainWindowController: NSWindowController?
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let popover:NSPopover = {
        let pop = NSPopover()
        pop.behavior = .transient
        return pop
    }()
    var mainDB: Database! = Database()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("16-black"))
            button.action = #selector(self.togglePopoverAttemt4(_:))
            button.target = self
        }
        popover.contentViewController = QuotesViewController.freshController()
        setDocIconVisibility(state: false)
        OSXVersion()
        localizeMenu()
        
        launchMenuItem.state = LaunchAtLogin.isEnabled ? .on : .off
        AppManager.shared.start()
        AppManager.shared.createAndAddFakeSessions()
        relamConfig()
    }
    
    func relamConfig(){
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
    }
    
    
    func localizeMenu(){
        
        menuFile.submenu?.title = "File".localized()
        menuWindows.submenu?.title = "Window".localized()
        menuRefresh2.item(at: 0)?.title = "Refresh".localized()
        menuHelp.submenu?.title = "Help".localized()
        subMenuHelp.item(at: 0)?.title = "Send Feedback".localized()
        subMenuHelp.item(at: 1)?.title = "Visit Website".localized()
        
        menuSubWindow.item(at: 0)?.title = "Minimize".localized()
        menuSubWindow.item(at: 1)?.title = "Zoom".localized()
        menuSubWindow.item(at: 3)?.title = "Bring All to Front".localized()
        
        menuTimeMatt.item(at: 0)!.title = "About TimeMatters".localized()
        menuTimeMatt.item(at: 2)!.title = "Quit TimeMatters".localized()
    }
    
    //MARK: other
    @IBAction func visitWebsiteAction(_ sender: Any) {
        let url = URL(string:webSiteUrl)!
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func sendFeedBackAction(_ sender: Any) {
        let service = NSSharingService(named: NSSharingService.Name.composeEmail)
        service?.recipients = ["hi@roboapps.co"]
        service?.subject = ""
        service?.perform(withItems: [""])
    }
    
    @IBAction func lanchAtLoginAction(_ sender: NSMenuItem) {
        
        sender.state = sender.state == .on ? .off : .on
        LaunchAtLogin.isEnabled = sender.state == .on ? true : false
        
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        mainDB.loadAndParceLogs()
    }
    
    @IBAction func resetStatistic(_ sender: Any) {
        
        let alert = NSAlert()
        alert.messageText = "Warning"
        alert.informativeText = "All saved data will be removed. Are you sure?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
            }
            mainDB.loadAndParceLogs()
        }
        
    }
    
    @IBAction func showAboutVC(_ sender: Any) {
        
        guard self.aboutVC == nil else {
            self.aboutVC?.window?.makeKeyAndOrderFront(self)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let mainWindow = storyboard.instantiateController(withIdentifier: "AboutViewController") as! NSWindowController
        mainWindow.showWindow(self)
        mainWindow.window?.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
        
        self.aboutVC = mainWindow
    }
    
    func showMainWindow(){
        
        guard self.mainWindowController == nil else {
            self.mainWindowController?.window?.makeKeyAndOrderFront(self)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let mainWindow = storyboard.instantiateController(withIdentifier: "mainWindowController") as! NSWindowController
        mainWindow.showWindow(self)
        mainWindow.window?.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
        
        self.mainWindowController = mainWindow
        closePopover(sender: nil)
    }
    
    
    @objc func togglePopoverAttemt4(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }

}
