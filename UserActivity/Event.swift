//
//  Event.swift
//  UserActivity
//
//  Created by Sergiy Kurash on 3/6/19.
//  Copyright © 2019 Sergiy Kurash. All rights reserved.
//

import Foundation

class Event {
    
    var event_time: Date?
    var description: String?
    var reason: ReasonType?
    var switcher: Switcher?
    
    enum ReasonType{
        
        case user, display, screen
    }
    
    enum Switcher{
        
        case on, off
    }
    
    init () {
        // uncomment this line if your class has been inherited from any other class
        //super.init()
    }
}
