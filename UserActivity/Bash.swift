//
//  Bash.swift
//  UserActivity
//
//  Created by RoboApps on 3/1/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Cocoa
import Foundation

class Bash {
    //public func shell(launchPath: String, arguments: [String]) -> String
    //{
    //    let task = Process()
    //    task.launchPath = launchPath
    //    task.arguments = arguments
    //
    //    let pipe = Pipe()
    //    task.standardOutput = pipe
    //    task.launch()
    //
    //    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    //    let output = String(data: data, encoding: String.Encoding.utf8)!
    //    print (output)
    //    if output.characters.count > 0 {
    //        //remove newline character.
    //        let lastIndex = output.index(before: output.endIndex)
    //        return String(output[output.startIndex ..< lastIndex])
    //    }
    //    return output
    //}
    //
    //func bash(command: String, arguments: [String]) -> String {
    //    let whichPathForCommand = shell(launchPath: "/bin/bash", arguments: [ "-l", "-c", "which \(command)" ])
    //    return shell(launchPath: whichPathForCommand, arguments: arguments)
    //}
    
    class func shell(_ command: String) -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        
        return output
    }
    
    class func shell(_ command: String, completion: @escaping (String) -> Void){
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        DispatchQueue.global().async {
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
            DispatchQueue.main.async {
                completion(output)
            }
        }
    }
}
//let currentBranch = bash(command: "pmset", arguments: ["-g"])
//print("current branch:\(currentBranch)")



