//
//  TrackProgress.swift
//  DEPNotify
//
//  Created by Joel Rennich on 2/16/17.
//  Copyright © 2017 Orchard & Grove Inc. All rights reserved.
//

import Foundation
import Cocoa

enum StatusState {
    case start
    case done
}

enum OtherLogs {
    static let jamf = "/var/log/jamf.log"
    static let filewave = "/var/log/fwcld.log"
    static let munki = ""
    static let none = ""
}

class TrackProgress: NSObject {
    
    // set up some defaults
    
    var path: String
    dynamic var statusText: String
    dynamic var command: String
    var status: StatusState
    let task = Process()
    let fm = FileManager()
    var additionalPath = OtherLogs.none
    var filesetCount = 0
    var fwDownloadsStarted = false
    
    // init
    
    override init() {
        
        path = "/var/tmp/depnotify.log"
        
        for arg in 0...(CommandLine.arguments.count - 1) {
            
            switch CommandLine.arguments[arg] {
            case "-path" :
                guard (CommandLine.arguments.count >= arg + 1) else { continue }
                path = CommandLine.arguments[arg + 1]
            case "-jamf" :
                additionalPath = OtherLogs.jamf
            case "-munki" :
                additionalPath = OtherLogs.munki
            case "-filewave" :
                additionalPath = OtherLogs.filewave
                statusText = "Downloading Filewave configuration"
            default :
                break
            }
        }
        
        statusText = "Starting configuration"
        command = ""
        status = .start
        task.launchPath = "/usr/bin/tail"
        task.arguments = ["-f", path, additionalPath]
        
    }
    
    // watch for updates and post them
    
    func run() {
        
        // check to make sure the file exists
        
        if !fm.fileExists(atPath: path) {
            // need to make the file
            fm.createFile(atPath: path, contents: nil, attributes: nil)
        }
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        let outputHandle = pipe.fileHandleForReading
        outputHandle.waitForDataInBackgroundAndNotify()
        
        var dataAvailable : NSObjectProtocol!
        dataAvailable = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                                                               object: outputHandle, queue: nil) {  notification -> Void in
                                                                let data = pipe.fileHandleForReading.availableData
                                                                if data.count > 0 {
                                                                    if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                                                                        //print("Task sent some data: \(str)")
                                                                        self.processCommands(commands: str as String)
                                                                    }
                                                                    outputHandle.waitForDataInBackgroundAndNotify()
                                                                } else {
                                                                    NotificationCenter.default.removeObserver(dataAvailable)
                                                                }
        }
        
        var dataReady : NSObjectProtocol!
        dataReady = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification,
                                                           object: pipe.fileHandleForReading, queue: nil) { notification -> Void in
                                                            print("Task terminated!")
                                                            NotificationCenter.default.removeObserver(dataReady)
        }
        
        task.launch()
        
        statusText = "Reticulating splines..."
        
    }
    
    func processCommands(commands: String) {
        
        let allCommands = commands.components(separatedBy: "\n")
        
        for line in allCommands {
            switch line.components(separatedBy: " ").first! {
            case "Status:" :
                statusText = line.replacingOccurrences(of: "Status: ", with: "")
            case "Command:" :
                command = line.replacingOccurrences(of: "Command: ", with: "")
            default:
                switch additionalPath {
                case OtherLogs.jamf :
                    if line.contains("jamf[") && ( line.contains("Installing") || line.contains("Executing")) {
                        
                        do {
                            let installerRegEx = try NSRegularExpression(pattern: ".*]: ", options: NSRegularExpression.Options.caseInsensitive)
                            let status = installerRegEx.stringByReplacingMatches(in: line, options: NSRegularExpression.MatchingOptions.anchored, range: NSMakeRange(0, line.characters.count), withTemplate: "")
                            statusText = status
                        } catch {
                            NSLog("Couldn't parse jamf.log")
                        }
                    }
                case OtherLogs.filewave :
                    if line.contains("Downloading Fileset:") {
                        
                        do {
                            let typePattern = "(?<=Fileset:)(.*)(?=ID:)"
                            let typeRange = line.range(of: typePattern,
                                                       options: .regularExpression)
                            let insertText = "Downloading: "
                            let wantedText = line[typeRange!].trimmingCharacters(in: .whitespacesAndNewlines)
                            statusText = "\(insertText) \(wantedText)"
                        }
                    }
                    else if line.contains("Installer") {
                        
                        do {
                            let typePattern = "(?<=Installer:\\s)(.*)(?=\\sfrom)"
                            let typeRange = line.range(of: typePattern,
                                                       options: .regularExpression)
                            let insertText = "Running Installer: "
                            let wantedText = line[typeRange!].trimmingCharacters(in: .whitespacesAndNewlines)
                            statusText = "\(insertText) \(wantedText)"
                        }
                    }
                    else if line.contains("Installed") {
                        do {
                            let typePattern = "(?<=Software:\\s)(.*)(?=\\sResult)"
                            let typeRange = line.range(of: typePattern,
                                                       options: .regularExpression)
                            let insertDL = "Installed: "
                            if typeRange != nil {
                                let wantedText = line[typeRange!].trimmingCharacters(in: .whitespacesAndNewlines)
                                statusText = "\(insertDL) \(wantedText)"
                            } else {
                                command = "DeterminateManualStep:"
                            }
                        }
                    }
                    else if line.contains("Done processing Fileset") {
                        do {
                            filesetCount += 1
                        }
                    }
                    else if line.contains("Requirements not met") {
                        do {
                            filesetCount -= 1
                        }
                    }
                    else if line.contains("About to download") && (fwDownloadsStarted == false) {
                        do {
                            fwDownloadsStarted = true
                            command = "Determinate: \(filesetCount * 2)"
                        }
                    }
                    else if line.contains("Result code: 0") {
                        do {
                            command = "DeterminateManualStep:"
                        }
                    }
                    else if line.contains("Installation(s) Completed.") {
                        do {
                            command = "Restart: Your DEP enrollment is over, lets reboot because it's fun."
                        }
                    }
                case OtherLogs.munki :
                    break
                case OtherLogs.none :
                    break
                default:
                    break
                }
                break
            }
        }
    }
}
