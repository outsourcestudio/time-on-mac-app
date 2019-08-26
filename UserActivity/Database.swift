//
//  Database.swift
//  UserActivity
//
//  Created by RoboApps on 3/2/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Foundation
import RealmSwift
import AppleScriptObjC // ASOC adds its own 'load scripts' method to NSBundle
import asl

class Database {
    
    // AppleScriptObjC object for communicating with iTunes
    var iTunesBridge: iTunesBridge?
    
    // restart and reset DB from menu
    var fromFiles = false
    
    var loading:Bool = false
    var timer = Timer()
    let timerInterval:TimeInterval = 300
    private var loadingList = [String:Bool]()
    {
        didSet {
            self.loading = Array(loadingList.values).contains(true)
            if !self.loading {
                UserDefaults.standard.set(Date(), forKey: "updateDate")
                let nc = NotificationCenter.default
                nc.post(name: NSNotification.Name("DatabaseHasChanged"), object: nil)
//                RouterDB().printAllEvents()
            }
        }
    }
    
    //MARK:
    
    init () {
        scheduledTimerWithTimeInterval()
        loadAndParceLogs()
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
        NSLog("counting..")
        loadAndParceLogs()
    }

    
    func loadAndParceLogs(){
        
        if fromFiles {
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
            }
        }
        
        loadBashNotif()
        loadBashUser()
//        loadBashScreenOFF()
//        loadBashScreenON()
        
//        longBash()
    }
    
    func longBash(){
        let rand = "\(Int.random(in: 1...9999))t"
        loadingList[rand] = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) {
            self.loadingList[rand] = false
        }
        
    }
    
    func loadBashNotif(){
        
        loadAppleBashNotif()
        
        let rand = "\(Int.random(in: 1...9999))n"
        loadingList[rand] = true
        Bash.shell("pmset -g log|grep -e \" Notification \"") { (notification_output) in
            let contentString = self.fromFiles ? notifFromFile() : notification_output
            self.generateEvents(output: contentString, reasonType: .display)
            self.loadingList[rand] = false
        }
    }
    
    func loadAppleBashNotif(){
//        let source = "do shell script \"/bin/bash\nwhoami\""
//
//        let script = NSAppleScript(source: source)!
//        var errorDict: NSDictionary? = nil
//        let output = script.executeAndReturnError(&errorDict)
//        print (output.stringValue ?? "nil")
//
//        let source2 = "set outputs to do shell script \"last grep " + output.stringValue! + "\""
//        print (source2)
//        let script2 = NSAppleScript(source: source2)!
//        var errorDict2: NSDictionary? = nil
//        let output2 = script2.executeAndReturnError(&errorDict2)
//        let xxx = output2.numberOfItems
//        print (output2.stringValue)
//
//        let source3 = "do shell script \"pmset -g log\""
//        print (source3)
//        let script3 = NSAppleScript(source: source3)!
//        var errorDict3: NSDictionary? = nil
//        let output3 = script3.executeAndReturnError(&errorDict3)
//        print (output3.stringValue)
//
//        // --------------------------------------------------------
//        let scriptFolderUrl = try! FileManager.default.url(for: .applicationScriptsDirectory,
//                                                           in: .userDomainMask, appropriateFor: nil, create: true)
//        if let scriptUrl = URL(string: "display.scpt", relativeTo: scriptFolderUrl) {
//            // --------------------------------------------------------
//            // same below
//            do {
//                let task = try NSUserUnixTask(url: scriptUrl)
//                task.execute(withArguments: [ "" ])
//                debugPrint("OK")
//            } catch let error {
//                debugPrint(error)
//            }
//        } else {
//            debugPrint("Script not found")
//        }
//        Bundle.main.loadAppleScriptObjectiveCScripts()
//        // create an instance of iTunesBridge script object for Swift code to use
//        let iTunesBridgeClass: AnyClass = NSClassFromString("iTunesBridge")!
//        self.iTunesBridge = iTunesBridgeClass.alloc() as! iTunesBridge
//        let whoami = self.iTunesBridge!.whoami
//        print (whoami)
//        let pmset = self.iTunesBridge!.display
//        print (pmset)
//        print(getBatteryState().flatMap{$0})
        
//        let apps = NSWorkspace.shared.runningApplications
//         [[NSWorkspace sharedWorkspace] runningApplications]
//        let curent NSWorkspace.shared.curr


    }
    
    
    func getBatteryState() -> [String?]
    {
        let task = Process()
        let pipe = Pipe()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["-g", "log"]
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
        
        let batteryArray = output.components(separatedBy: ";")
        let source = output.components(separatedBy: "'")[1]
        let state = batteryArray[1].trimmingCharacters(in: NSCharacterSet.whitespaces).capitalized
        let percent = String.init(batteryArray[0].components(separatedBy: ")")[1].trimmingCharacters(in: NSCharacterSet.whitespaces).characters.dropLast())
        var remaining = String.init(batteryArray[2].characters.dropFirst().split(separator: " ")[0])
        if(remaining == "(no"){
            remaining = "Calculating"
        }
        return [source, state, percent, remaining]
    }

    func loadBashUser(){
        let rand = "\(Int.random(in: 1...9999))u"
        loadingList[rand] = true
        let whoami = Bash.shell("whoami")
        var bash_string = "last grep " + whoami + " | grep console"
        bash_string = bash_string.replacingOccurrences(of: "\n", with: "",
                                                       options: NSString.CompareOptions.literal, range:nil)
        Bash.shell(bash_string) { (notification_output) in
            let contentString = self.fromFiles ? lastUserFromFile() : notification_output
            self.generateEvents(output: contentString, reasonType: .user)
            self.loadingList[rand] = false
        }
        
    }

    func loadBashScreenOFF(){
        let datStr = ""//" --start '2019-02-09'"
        let rand = "\(Int.random(in: 1...9999))off"
        loadingList[rand] = true
        Bash.shell("log show " + datStr + "| grep loginwindow | grep lockScreen | grep \"about to call lockScreen\"") { (notification_output) in
            self.generateEvents(output: notification_output, reasonType: .screen)
            self.loadingList[rand] = false
//            print(self.loadingList)
        }
    }

    func loadBashScreenON(){
        let datStr = ""//" --start '2019-02-09'"
        let rand = "\(Int.random(in: 1...9999))on"
        loadingList[rand] = true
        Bash.shell("log show " + datStr + "| grep loginwindow | grep screenlock") { (notification_output) in
            self.generateEvents(output: notification_output, reasonType: .screen)
            self.loadingList[rand] = false
        }
    }
    
    func generateEvents(output: String, reasonType: ReasonType){
        
        let realm = try? Realm()
        realm?.beginWrite()
        
        var lines: [String] = []
//        var mutable_events = events
        output.enumerateLines { line, _ in
            lines.append(line)
        }
        for (_, element) in lines.enumerated() {
//            print (element)
            switch reasonType {
            case .display:
                let t_string_array = element.components(separatedBy: " Notification ")
                let time_string = t_string_array[0].replacingOccurrences(of: " ", with: "",
                                                                         options: NSString.CompareOptions.literal, range:nil)
                let date = time_string.date_from_string() //date_from_string(date_string: time_string)
                if date == nil  || date!.oldThan(days: 8){
                    continue
                }
                let event = Event()
                event.event_time = date // пишем время по гринвичу!!
                event.reason = .display
                if element.contains("Display is turned on"){
                    event.switcher = .on
                    realm?.add(event, update: true)
                } else if element.contains("Display is turned off"){
                    event.switcher = .off
                    realm?.add(event, update: true)
                }
//                print (event)
                
            case .user:
                let regex = try! NSRegularExpression(pattern: "^.*console[ ]+", options: NSRegularExpression.Options.caseInsensitive)
                let range = NSMakeRange(0, element.count)
                let modString = regex.stringByReplacingMatches(in: element, options: [], range: range, withTemplate: "")
                
//                print(modString)

                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy EEE MMM d HH:mm"//this your string date format
                dateFormatter.timeZone = TimeZone.current // пишем время по гринвичу!!
                let t_string_array = modString.components(separatedBy: " - ").count < 2 ? modString.components(separatedBy: "   still logged in") : modString.components(separatedBy: " - ")
                if t_string_array.count == 0 {
                    continue
                }
                var date_string = t_string_array[0]
                let year = Date()
                date_string = year.year + " " + date_string // ПРОВЕРИТЬ НА БУДУЩЕЕ
                var date = dateFormatter.date(from: date_string)
                if date == nil{
                    continue
                }
                
                if date?.compare(Date()) == .orderedDescending && date != nil { // если дата больше текущей отнимаем год
                    date = Calendar.current.date(byAdding: .year, value: -1, to: date!)!
                }
                if date!.oldThan(days: 8){
                    continue
                }
                
                let event = Event()
                event.reason = .user
                event.switcher = .on
                event.event_time = date
//                events.append(event)
                realm?.add(event, update: true)
                
                if modString.contains("(") && modString.contains(")"), let date = date {
                    let endSecond = getSecondFromTime(string: modString)
                    let calendar = Calendar.current
                    let endDate = calendar.date(byAdding: .second, value: endSecond, to: date)!
                    
                    if endDate.oldThan(days: 8){
                        continue
                    }
                    
                    let event = Event()
                    event.reason = .user
                    event.switcher = .off
                    event.event_time = endDate
//                    events.append(event)
                    realm?.add(event, update: true)
                }
//                print (event)
                
                // end session time logic
                // 1 - check for latest "still logged in"
                // calculate date from parentesis
//                work      console                   Sat Nov  3 19:54 - 20:09  (00:15)
//                work      console                   Sat Nov  3 19:06 - crash  (00:47)
//                work      console                   Sun Dec  9 16:17 - 00:39  (08:22)
//                work      console                   Fri Dec  7 11:07 - 16:14 (2+05:07)
//                work      console                   Thu Jan  3 10:41 - 00:34  (13:53)
//                work      console                   Thu Jan  3 10:40 - shutdown  (13:53)
//                work      console                   Wed Mar  6 07:59   still logged in
//                work      console                   Tue Mar  5 23:37 - 00:38  (01:00)
            case .screen:
                let on = element.contains("about to call lockScreen") ? false : true
                let t_string_array = element.components(separatedBy: " 0x")
                let time_string = t_string_array[0]//.replacingOccurrences(of: " ", with: "",
//                                                                         options: NSString.CompareOptions.literal, range:nil)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                //"2019-03-05 09:41:44.982274+0200"
                let date = dateFormatter.date(from: time_string)
                if date == nil || date!.oldThan(days: 8){
                    continue
                }
                let event = Event()
                event.event_time = date // пишем время по гринвичу!!
                event.reason = .screen
                event.switcher = on ? .on : .off
//                events.append(event)
                realm?.add(event, update: true)
            }
        }
        try? realm?.commitWrite()
    }
    
    private func getSecondFromTime(string:String) -> Int{
        if let pos_f = string.indexOf(target: "("), let pos_e = string.indexOf(target: ")") {
            if let res = string.substring(with: NSRange(location: pos_f+1, length: pos_e - pos_f-1)) {
                let a = res.components(separatedBy: "+")
                var daySecond = 0
                 if a.count > 1, let dayStr = a.first, let days = Int(dayStr) {
                    let timeStr = a[1]
                    daySecond = days * 24 * 60 * 60 + timeStr.toSecond(format: "HH:mm")
                }else if a.count > 0 {
                    let timeStr = a[0]
                    daySecond = timeStr.toSecond(format: "HH:mm")
                }
                return daySecond
            }
        }
        return 0
    }
    
    
}

