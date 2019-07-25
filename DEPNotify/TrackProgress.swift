//
//  TrackProgress.swift
//  DEPNotify
//
//  Created by Joel Rennich on 2/16/17.
//  Copyright © 2017 Orchard & Grove Inc. All rights reserved.
//  FileWave log processing added by Damon O'Hare and Dan DeRusha
//  Additional Jamf log processing added by Zack Thompson

import Foundation

enum StatusState {
    case start
    case done
}

enum OtherLogs {
    static let jamf = "/var/log/jamf.log"
    static let filewave = "/var/log/fwcld.log"
    static let munki = "/Library/Managed Installs/Logs/ManagedSoftwareUpdate.log"
    static let none = ""
}

class TrackProgress: NSObject {
    
    // set up some defaults
    
    var path: String
    @objc dynamic var statusText: String
    @objc dynamic var command: String
    var status: StatusState
    let task = Process()
    let fm = FileManager()
    var additionalPath = OtherLogs.none
    var fwDownloadsStarted = false
    var filesets = Set<String>()
    
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
                                                            NSLog("Task terminated!")
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
                    // Define Variables
                    struct globalVariables {
                        static var fileVaultState = "Disabled"
                        static var failedReason = "Unable to determine..."
                    }
                    
                    let actions = ["Installing", "Executing Policy", "Downloading", "Successfully installed", "failed", "Error:", "FileVault", "Encrypt", "Encryption", "DEPNotify Quit"]
                    
                    // Reads a file and returns the lines -- used to get the item and reason an install failed.
                    func readFile(path: String) -> Array<String> {
                        do {
                            let contents:NSString = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
                            let trimmed:String = contents.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                            let lines:Array<String> =  NSString(string: trimmed).components(separatedBy: .newlines)
                            return lines
                        } catch {
                            NSLog("Unable to read file: \(path)");
                            return [String]()
                        }
                    }
                    
                    for action in actions where line.contains(action) {
                        if (!(line.range(of: "flat package") != nil)) && (!(line.range(of: "bom") != nil)) && (!(line.range(of: "an Apple package...") != nil)) && (!(line.range(of: "com.jamfsoftware.task.errors") != nil)) {
                            
                            switch true {
                                
                            case line.range(of: "Downloading") != nil:
                                let lineDownloadingItem = line.components(separatedBy: "CasperShare/")
                                let getDownloadingItem = lineDownloadingItem[1]
                                NSLog(getDownloadingItem)
                                let pattern = "(%20)"  // If you have prefixes on packages that you'd like to remove, you can add the pattern here, like so:  "(%20)|(Prefix.Postfix)|(ExStr)"
                                let removeRegex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                                let downloadingItem = removeRegex.stringByReplacingMatches(in: getDownloadingItem, options: [], range: NSRange(location: 0, length: getDownloadingItem.count), withTemplate: "")
                                
                                if !(downloadingItem.isEmpty) {
                                    NSLog("Downloading:  \(downloadingItem)")
                                    statusText = "Downloading:  \(downloadingItem)"
                                }
                                
                            case line.range(of: "Installing") != nil:
                                let lineInstallItem = line.components(separatedBy: "Installing ")
                                let getInstallItem = lineInstallItem[1]
                                let pattern = "\\[.*?\\]\\s"  // If you have prefixes on packages that you'd like to remove, you can add the pattern here, like so:  "(%20)|(Prefix.Postfix)|(ExStr)"
                                let removeRegex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                                let installItem = removeRegex.stringByReplacingMatches(in: getInstallItem, options: [], range: NSRange(location: 0, length: getInstallItem.count), withTemplate: "")
                                
                                if !(installItem.isEmpty) {
                                    NSLog("Installing:  \(installItem)")
                                    statusText = "Installing: \(installItem)"
                                }
                            
                            case line.range(of: "Executing Policy") != nil:
                                let lineInstallItem = line.components(separatedBy: "]: Executing Policy ")
                                let getInstallItem = lineInstallItem[1]
                                let pattern = "\\[.*?\\]\\s"  // If you have prefixes on packages that you'd like to remove, you can add the pattern here, like so:  "(%20)|(Prefix.Postfix)|(ExStr)"
                                let removeRegex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                                let installItem = removeRegex.stringByReplacingMatches(in: getInstallItem, options: [], range: NSRange(location: 0, length: getInstallItem.count), withTemplate: "")
                                
                                if !(installItem.isEmpty) {
                                    NSLog("Getting:  \(installItem)")
                                    statusText = "Getting: \(installItem)"
                                }
                                
                            case line.range(of: "Successfully installed") != nil:
                                let lineInstalledItem = line.components(separatedBy: "]: Successfully installed")
                                let getInstalledItem = lineInstalledItem[1]
                                let pattern = "\\s*\\[.*?\\]\\s*"  // If you have prefixes on packages that you'd like to remove, you can add the pattern here, like so:  "(%20)|(Prefix.Postfix)|(ExStr)"
                                let removeRegex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                                let installedItem = removeRegex.stringByReplacingMatches(in: getInstalledItem, options: [], range: NSRange(location: 0, length: getInstalledItem.count), withTemplate: "")
                                
                                if !(installedItem.isEmpty) {
                                    NSLog("Successfully installed:  \(installedItem)")
                                    statusText = "Successfuly installed: \(installedItem)"
                                }
                                
                            case line.range(of: "failed") != nil:
                                let logLines = readFile(path: OtherLogs.jamf)
                                let lineFailedItem = (logLines.firstIndex(where: {$0.contains("\(line)")}))
                                let lineItemInstalled = lineFailedItem! - 1
                                let lineFailedReason = lineFailedItem! + 1
                                let getInstalledItem = logLines[lineItemInstalled].components(separatedBy: "Installing ")
                                if (logLines[lineFailedReason].range(of: "Cannot install on volume / because it is disabled.") != nil) {
                                    let getFailedReason = logLines[lineFailedReason].components(separatedBy: "installer: ")
                                    NSLog("\(getFailedReason)")
                                    globalVariables.failedReason = getFailedReason[1]
                                    NSLog(globalVariables.failedReason)
                                }
                                else {
                                    let getFailedReason = logLines[lineFailedItem!].components(separatedBy: "installer: ")
                                    NSLog("\(getFailedReason)")
                                    globalVariables.failedReason = getFailedReason[1]
                                    NSLog(globalVariables.failedReason)
                                }
                                if !(getInstalledItem[1].isEmpty) {
                                    NSLog("Failed to install:  \(getInstalledItem[1])  Reason:  \(globalVariables.failedReason)")
                                    statusText = "Failed to install:  \(getInstalledItem[1])  Reason:  \(globalVariables.failedReason)"
                                }
                                
                            case line.range(of: "Error:") != nil:
                                let lineErrorItem = line.components(separatedBy: "Error: ")
                                let getErrorItem = lineErrorItem[1]
                                let pattern = "(%20)"  // If you have prefixes on packages that you'd like to remove, you can add the pattern here, like so:  "(%20)|(Prefix.Postfix)|(ExStr)"
                                let removeRegex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                                let errorItem = removeRegex.stringByReplacingMatches(in: getErrorItem, options: [], range: NSRange(location: 0, length: getErrorItem.count), withTemplate: "")
                                
                                if !(errorItem.isEmpty) {
                                    NSLog("Error:  \(errorItem)")
                                    statusText = "Error installing: \(errorItem)"
                                }
                                
                            case (action.range(of: "FileVault") != nil) || (action.range(of: "Encrypt") != nil) || (action.range(of: "Encryption") != nil):
                                if (globalVariables.fileVaultState == "Disabled") {
                                    statusText = "Configuring for FileVault Encryption..."
                                    command = "FileVault: FileVault has been enabled on this machine and a reboot will be required to start the encryption process."
                                    globalVariables.fileVaultState = "Enabled"
                                }
                                
                            case action.range(of: "DEPNotify Quit") != nil:
                                statusText = "Setup Complete!"
                                if (globalVariables.fileVaultState == "Enabled") {
                                    command = "Quit:  Setup Complete!  A reboot is needed to complete the encryption process."
                                }
                                else {
                                    command = "Quit:  Setup Complete!"
                                }
                                
                            default:
                                break
                                
                            }
                        }
                    }
                case OtherLogs.filewave :
                    if line.contains("Done processing Fileset") {
                        do {
                            let typePattern = "(?<=Fileset\\sContainer\\sID\\s)(.*)"
                            let typeRange = line.range(of: typePattern,
                                                       options: .regularExpression)
                            let wantedText = line[typeRange!].trimmingCharacters(in: .whitespacesAndNewlines)
                            filesets.insert(wantedText)
                        }
                    }
                    else if line.contains("download/activation cancelled") {
                        do {
                            let typePattern = "(?<=Fileset\\sID\\s)(.*)(?=\\swere\\snot\\smet)"
                            let typeRange = line.range(of: typePattern,
                                                       options: .regularExpression)
                            let wantedText = line[typeRange!].trimmingCharacters(in: .whitespacesAndNewlines)
                            filesets.remove(wantedText)
                        }
                    }
                    else if line.contains("verifyAllFilesAndFolders") {
                        do {
                            let typePattern = "(?<=ID:\\s)(.*)"
                            let typeRange = line.range(of: typePattern,
                                                       options: .regularExpression)
                            let wantedText = line[typeRange!].trimmingCharacters(in: .whitespacesAndNewlines)
                            filesets.remove(wantedText)
                        }
                    }
                    else if line.contains("about to download") && (fwDownloadsStarted == false) {
                        do {
                            fwDownloadsStarted = true
                            command = "Determinate: \(filesets.count * 2)"
                        }
                    }
                    else if line.contains("Downloading Fileset:") {
                        
                        do {
                            let typePattern = "(?<=Fileset:)(.*)(?=ID:)"
                            let typeRange = line.range(of: typePattern,
                                                       options: .regularExpression)
                            let insertText = "Downloading: "
                            let wantedText = line[typeRange!].trimmingCharacters(in: .whitespacesAndNewlines)
                            statusText = "\(insertText) \(wantedText)"
                        }
                    }
                    else if line.contains("Create all folders of fileset") {
                        
                        do {
                            let typePattern = "(?<=Create\\sall\\sfolders\\sof\\sfileset\\sID\\s)(.*)(?=\\sID:)"
                            let typeRange = line.range(of: typePattern,
                                                       options: .regularExpression)
                            let insertText = "Installing: "
                            let wantedText = line[typeRange!].trimmingCharacters(in: .whitespacesAndNewlines)
                            statusText = "\(insertText) \(wantedText)"
                        }
                    }
                    else if line.contains("= HEADER =") {
                        do {
                            fwDownloadsStarted = false
                            filesets.removeAll()
                            command = "DeterminateOffReset:"
                            statusText = "Please wait while FileWave continues processing..."
                        }
                    }
                case OtherLogs.munki :
                    if (line.contains("Installing") || line.contains("Downloading"))
                        && !line.contains(" at ") && !line.contains(" from ") {
                        
                        do {
                            let installerRegEx = try NSRegularExpression(pattern: "^.{0,27}")
                            let status = installerRegEx.stringByReplacingMatches(in: line,
                                                                                 options: NSRegularExpression.MatchingOptions.anchored,
                                                                                 range: NSMakeRange(0, line.count),
                                                                                 withTemplate: "").trimmingCharacters(in: .whitespacesAndNewlines)
                            statusText = status
                        } catch {
                            NSLog("Couldn't parse ManagedSoftwareUpdate.log")
                        }
                    }
                case OtherLogs.none :
                    break
                default:
                    break
                }
                break
            }
        }
    }
    
    func killCommandFile() {
        // delete the command file
        
        let fs = FileManager.init()
        
        if fs.isDeletableFile(atPath: path) {
            do {
                try fs.removeItem(atPath: path)
                NSLog("Deleted DEPNotify command file")
            } catch {
                NSLog("Unable to delete command file")
            }
        }
    }
}
