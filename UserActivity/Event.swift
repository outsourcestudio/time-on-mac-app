//
//  Event.swift
//  UserActivity
//
//  Created by RoboApps on 3/6/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Foundation
import RealmSwift

class Event:Object {
    
    @objc dynamic var id: String!
    @objc dynamic var event_time: Date?{
        didSet{
            id = createID()
        }
    }
    @objc dynamic var title: String = ""
        {
        didSet{
            id = createID()
        }
    }
    @objc dynamic var reason: ReasonType = .user
        {
        didSet{
            id = createID()
        }
    }
    @objc dynamic var switcher: Switcher = .on
        {
        didSet{
            id = createID()
        }
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    private func createID() -> String{
        var res = "\(Date().timeIntervalSince1970)"
        
        if let d = event_time {
            res  = "\(d.timeIntervalSince1970)" + reason.rawValue() + switcher.rawValue()
        }
        
        return res
    }
}

@objc enum ReasonType : Int {
    case user = 0
    case display
    case screen
    
    public func rawValue() -> String {
        switch self {
        case .user:
            return "user"
        case .display:
            return "display"
        case .screen:
            return "screen"
            
        }
    }
}

@objc enum Switcher: Int {
    case on = 0
    case off
    public func rawValue() -> String {
        switch self {
        case .on:
            return "on"
        case .off:
            return "off"
        }
    }
}
