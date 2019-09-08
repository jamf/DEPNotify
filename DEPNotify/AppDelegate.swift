//
//  AppDelegate.swift
//  DEPNotify
//
//  Created by Joel Rennich on 2/16/17.
//  Copyright © 2017 Orchard & Grove Inc. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

    }

    override func awakeFromNib() {

        // wait until .AppleSetupDone is in place
//
//        let fm = FileManager.init()
//
//        while !fm.fileExists(atPath: "/var/db/.AppleSetupDone") {
//            print("Waiting...")
//            RunLoop.main.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantFuture)
//        }

        // wait until the Dock is running. We should do this via KVO, but it's not all there in Swift yet
        
        var dockRunning = 0
        let ws = NSWorkspace.shared

        while dockRunning == 0 {
            print("Waiting for the Dock")
            dockRunning = ws.runningApplications.filter({ $0.bundleIdentifier == "com.apple.dock" }).count
            RunLoop.main.run(mode: RunLoop.Mode.default, before: Date.distantFuture)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

