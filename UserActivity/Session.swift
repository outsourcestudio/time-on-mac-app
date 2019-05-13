//
//  Session.swift
//  UserActivity
//
//  Created by RoboApps on 3/2/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Foundation
import RealmSwift

class Session:Object {
    
    var start_time: Date!
    var end_time: Date?
    var reason_on: String?
    var reason_off: String?
    var period: TimeInterval?

}
