//
//  Support.swift
//  Swift-AppleScriptObjC
//

import Cocoa



@objc(NSObject) protocol iTunesBridge {
    
    // Important: ASOC does not bridge C primitives, only Cocoa classes and objects,
    // so Swift Bool/Int/Double values MUST be explicitly boxed/unboxed as NSNumber
    // when passing to/from AppleScript.
    
    var whoami: String { get }
    var display: String { get }
}


