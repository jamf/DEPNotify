//
//  ViewController.swift
//  DEPNotify
//
//  Created by Joel Rennich on 2/16/17.
//  Copyright © 2017 Orchard & Grove Inc. All rights reserved.
//

import Cocoa

private var statusContext = 0
private var commandContext = 1

class ViewController: NSViewController {

    @IBOutlet weak var MainText: NSTextField!
    @IBOutlet weak var ProgressBar: NSProgressIndicator!
    @IBOutlet weak var StatusText: NSTextField!
    @IBOutlet weak var LogoCell: NSImageCell!
    @IBOutlet var myView: NSView!
    @IBOutlet weak var helpButton: NSButton!

    var tracker = TrackProgress()

    var helpURL = String()

    var determinate = false
    var totalItems: Double = 0
    var currentItem = 0

    var notify = false

    var logo: NSImage?
    var notificationImage: NSImage?

    var activateEachStep = false

    let myWorkQueue = DispatchQueue(label: "menu.nomad.DEPNotify.background_work_queue", attributes: [])


    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the background color to white
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = CGColor.white
        var isOpaque = false
        ProgressBar.startAnimation(nil)

        tracker.addObserver(self, forKeyPath: "statusText", options: .new, context: &statusContext)
        tracker.addObserver(self, forKeyPath: "command", options: .new, context: &commandContext)
        tracker.run()

        NSApp.activate(ignoringOtherApps: true)

        NSApp.windows[0].makeKeyAndOrderFront(self)

    }

    override func viewDidAppear() {
        //Customize the window's title bar
        let window = self.view.window
        
        if !CommandLine.arguments.contains("-oldskool") {
            window?.styleMask.insert(NSWindowStyleMask.unifiedTitleAndToolbar)
            window?.styleMask.insert(NSWindowStyleMask.fullSizeContentView)
            window?.styleMask.insert(NSWindowStyleMask.titled)
            window?.toolbar?.isVisible = false
            window?.titleVisibility = .hidden
            window?.titlebarAppearsTransparent = true
        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    func updateStatus(status: String) {

        self.StatusText.stringValue = status
        print(self.StatusText.stringValue)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &statusContext {
            if let newValue = change?[.newKey] {
                print(newValue)
                print("Change observed")
                updateStatus(status: newValue as! String)
                if notify {
                    sendNotification(text: newValue as! String)
                }
                if determinate {
                    currentItem += 1
                    ProgressBar.increment(by: 1)
                    if activateEachStep {
                        NSApp.activate(ignoringOtherApps: true)
                        NSApp.windows[0].makeKeyAndOrderFront(self)
                    }
                }
            } else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        } else if context == &commandContext {
            if let newValue = change?[.newKey] {
                print("Command observed")
                print(newValue)
                processCommand(command: newValue as! String)
            } else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }

        }
    }

    func processCommand(command: String) {

        switch command.components(separatedBy: " ").first! {

        case "Alert:" :
            let alertController = NSAlert()
            alertController.messageText = command.replacingOccurrences(of: "Alert: ", with: "")
            alertController.addButton(withTitle: "Ok")
            alertController.beginSheetModal(for: NSApp.windows[0])

        case "Determinate:" :
            
            determinate = true
            ProgressBar.isIndeterminate = false
            
            // default to 1 if we can't make a number
            totalItems = Double(command.replacingOccurrences(of: "Determinate: ", with: "")) ?? 1
            ProgressBar.maxValue = totalItems
            currentItem = 0
            ProgressBar.startAnimation(nil)

        case "DeterminateManual:" :
            
            determinate = false
            ProgressBar.isIndeterminate = false
            
            // default to 1 if we can't make a number
            totalItems = Double(command.replacingOccurrences(of: "DeterminateManual: ", with: "")) ?? 1
            ProgressBar.maxValue = totalItems
            currentItem = 0
            ProgressBar.startAnimation(nil)
            
        case "DeterminateManualStep:" :
            
            // default to 1 if we can't make a number
            let stepMove = Int(Double(command.replacingOccurrences(of: "DeterminateManualStep: ", with: "")) ?? 1 )
            currentItem += stepMove
            ProgressBar.increment(by: 1)
            if activateEachStep {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.windows[0].makeKeyAndOrderFront(self)
            }
            
        case "DeterminateOff:" :
            
            determinate = false
            ProgressBar.isIndeterminate = true
            ProgressBar.stopAnimation(nil)
            
        case "DeterminateOffReset:" :
            
            determinate = false
            currentItem = 0
            ProgressBar.increment(by: -1000)
            ProgressBar.isIndeterminate = true
            ProgressBar.stopAnimation(nil)

        case "Help:" :
            helpButton.isHidden = false
            helpURL = command.replacingOccurrences(of: "Help: ", with: "")

        case "Image:" :
            logo = NSImage.init(byReferencingFile: command.replacingOccurrences(of: "Image: ", with: ""))
            LogoCell.image = logo
            LogoCell.imageScaling = .scaleProportionallyUpOrDown
            LogoCell.imageAlignment = .alignCenter

        case "Logout:" :
            let alertController = NSAlert()
            alertController.messageText = command.replacingOccurrences(of: "Logout: ", with: "")
            alertController.addButton(withTitle: "Logout")
            //alertController.addButton(withTitle: "Quit")
            alertController.beginSheetModal(for: NSApp.windows[0]) { response in
                self.quitSession()
                NSApp.terminate(self)
            }

        case "LogoutNow:":
            self.quitSession()

        case "MainText:" :
            // Need to do two replacingOccurrences since we are replacing with different values
            let newlinecommand = command.replacingOccurrences(of: "\\n", with: "\n")
            MainText.stringValue = newlinecommand.replacingOccurrences(of: "MainText: ", with: "")

        case "Notification:" :
            sendNotification(text: command.replacingOccurrences(of: "Notification: ", with: ""))

        case "NotificationImage:" :
            notificationImage = NSImage.init(byReferencingFile: command.replacingOccurrences(of: "NotificationImage: ", with: ""))

        case "NotificationOn:" :
            notify = true

        case "WindowStyle:" :
            switch command.replacingOccurrences(of: "WindowStyle: ", with: "") {
            case "Activate" :
                NSApp.activate(ignoringOtherApps: true)
                NSApp.windows[0].makeKeyAndOrderFront(self)
            case "ActivateOnStep" :
                activateEachStep = true
            case "NotMovable" :
                NSApp.windows[0].center()
                NSApp.windows[0].isMovable = false
            case "JoshQuick" :
                if #available(OSX 10.12, *) {
                    let windowTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {_ in
                        NSApp.activate(ignoringOtherApps: true)
                        NSApp.windows[0].makeKeyAndOrderFront(self)
                    })
                    windowTimer.fire()
                } else {
                    // Fallback on earlier versions
                }
            default :
                break
            }

        case "WindowTitle:" :
            let title = command.replacingOccurrences(of: "WindowTitle: ", with: "")
            NSApp.windows[0].title = title

        case "Quit" :
            NSApp.terminate(self)

        case "Quit:" :
            let alertController = NSAlert()
            alertController.messageText = command.replacingOccurrences(of: "Quit: ", with: "")
            alertController.addButton(withTitle: "Quit")
            alertController.beginSheetModal(for: NSApp.windows[0]) { response in
                NSApp.terminate(self)
            }

        case "Restart:" :
            let alertController = NSAlert()
            alertController.messageText = command.replacingOccurrences(of: "Restart: ", with: "")
            alertController.addButton(withTitle: "Restart")
            //alertController.addButton(withTitle: "Quit")
            alertController.beginSheetModal(for: NSApp.windows[0]) { response in
                self.reboot()
                NSApp.terminate(self)
            }

        case "RestartNow:" :
            self.reboot()

        default:
            break
        }
    }

    func quitSession() {
        var targetDesc: AEAddressDesc = AEAddressDesc.init()
        var psn = ProcessSerialNumber(highLongOfPSN: UInt32(0), lowLongOfPSN: UInt32(kSystemProcess))
        var eventReply: AppleEvent = AppleEvent(descriptorType: UInt32(typeNull), dataHandle: nil)
        var eventToSend: AppleEvent = AppleEvent(descriptorType: UInt32(typeNull), dataHandle: nil)

        var status: OSErr = AECreateDesc(
            UInt32(typeProcessSerialNumber),
            &psn,
            MemoryLayout<ProcessSerialNumber>.size,
            &targetDesc
        )

        status = AECreateAppleEvent(
            UInt32(kCoreEventClass),
            kAELogOut,
            &targetDesc,
            AEReturnID(kAutoGenerateReturnID),
            AETransactionID(kAnyTransactionID),
            &eventToSend
        )

        AEDisposeDesc(&targetDesc)

        let osstatus = AESendMessage(
            &eventToSend,
            &eventReply,
            AESendMode(kAENormalPriority),
            kAEDefaultTimeout
        )

    }

    func reboot() {
        var targetDesc: AEAddressDesc = AEAddressDesc.init()
        var psn = ProcessSerialNumber(highLongOfPSN: UInt32(0), lowLongOfPSN: UInt32(kSystemProcess))
        var eventReply: AppleEvent = AppleEvent(descriptorType: UInt32(typeNull), dataHandle: nil)
        var eventToSend: AppleEvent = AppleEvent(descriptorType: UInt32(typeNull), dataHandle: nil)

        var status: OSErr = AECreateDesc(
            UInt32(typeProcessSerialNumber),
            &psn,
            MemoryLayout<ProcessSerialNumber>.size,
            &targetDesc
        )

        status = AECreateAppleEvent(
            UInt32(kCoreEventClass),
            kAERestart,
            &targetDesc,
            AEReturnID(kAutoGenerateReturnID),
            AETransactionID(kAnyTransactionID),
            &eventToSend
        )

        AEDisposeDesc(&targetDesc)

        let osstatus = AESendMessage(
            &eventToSend,
            &eventReply,
            AESendMode(kAENormalPriority),
            kAEDefaultTimeout
        )
        
    }

    func sendNotification(text: String) {
        let notification = NSUserNotification()

        if logo != nil {
            notification.contentImage = logo
        }

        notification.title = "Setup notification"
        notification.informativeText = text
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    @IBAction func HelpClick(_ sender: Any) {
        NSWorkspace.shared().open(URL(string: helpURL)!)
    }
}
