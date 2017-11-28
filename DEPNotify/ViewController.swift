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

var background: Background?

class ViewController: NSViewController {
    
    @IBOutlet weak var MainTitle: NSTextField!
    @IBOutlet weak var MainText: NSTextField!
    @IBOutlet weak var ProgressBar: NSProgressIndicator!
    @IBOutlet weak var StatusText: NSTextField!
    @IBOutlet weak var LogoCell: NSImageCell!
    @IBOutlet weak var ImageCell: NSImageCell!
    @IBOutlet var myView: NSView!
    @IBOutlet weak var helpButton: NSButton!
    @IBOutlet weak var continueButton: NSButton!
    
    var tracker = TrackProgress()
    
    var helpURL = String()
    
    var determinate = false
    var totalItems: Double = 0
    var currentItem = 0
    
    var notify = false
    
    var logo: NSImage?
    var maintextImage: NSImage?
    var notificationImage: NSImage?
    
    var activateEachStep = false
    
    var killCommandFile = false
    
    var quitKey = "x"
    
    let myWorkQueue = DispatchQueue(label: "menu.nomad.DEPNotify.background_work_queue", attributes: [])
    
   var agreementButton : Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the background color to white
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = CGColor.white
        //var isOpaque = false
        ProgressBar.startAnimation(nil)
        
        tracker.addObserver(self, forKeyPath: "statusText", options: .new, context: &statusContext)
        tracker.addObserver(self, forKeyPath: "command", options: .new, context: &commandContext)
        tracker.run()
        
        NSApp.activate(ignoringOtherApps: true)
        
        NSApp.windows[0].makeKeyAndOrderFront(self)
        
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.flagsChanged) {
            self.flagsChanged(with: $0)
            return $0
        }
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown) {
            self.keyDown(with: $0)
            return $0
        }
    }
    
    override func viewDidAppear() {
        //Customize the window's title bar
        let window = self.view.window
        
        if !CommandLine.arguments.contains("-oldskool") {
            window?.styleMask.insert(NSWindow.StyleMask.unifiedTitleAndToolbar)
            window?.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
            window?.styleMask.insert(NSWindow.StyleMask.titled)
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
            
        // Put a Continue button at the bottom of the screen
        case "ContinueButton" :
            continueButton.isHidden = false

        // Put a Continue button at the bottom of the screen to display an EULA
        case "ContinueButtonAgreement" :
            continueButton.isHidden = false
            agreementButton = true

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
            
        case "KillCommandFile:" :
            killCommandFile = true
            
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
            
        case "MainText:":
            // Need to do two replacingOccurrences since we are replacing with different values
            let newlinecommand = command.replacingOccurrences(of: "\\n", with: "\n")
            MainText.stringValue = newlinecommand.replacingOccurrences(of: "MainText: ", with: "")
            ImageCell.image = NSImage.init(byReferencingFile: "")
            
        case "MainTextImage:" :
            maintextImage = NSImage.init(byReferencingFile: command.replacingOccurrences(of: "MainTextImage: ", with: ""))
            ImageCell.image = maintextImage
            ImageCell.imageScaling = .scaleProportionallyUpOrDown
            ImageCell.imageAlignment = .alignCenter
            MainText.stringValue = ""
            MainTitle.stringValue = ""
            
        case "MainTitle:" :
            // Need to do two replacingOccurrences since we are replacing with different values
            let newlinecommand = command.replacingOccurrences(of: "\\n", with: "\n")
            MainTitle.stringValue = newlinecommand.replacingOccurrences(of: "MainTitle: ", with: "")
            ImageCell.image = NSImage.init(byReferencingFile: "")
            
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
            
        case "QuitKey:" :
            let quitKeyTemp = command.replacingOccurrences(of: "QuitKey: ", with: "")
            
            if quitKeyTemp.count == 1 {
                
                // exclude "q" as that's the system logout chord
                
                if quitKeyTemp != "q" {
                    quitKey = quitKeyTemp
                }
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
        
        if killCommandFile {
            tracker.killCommandFile()
        }
        
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
        
        if killCommandFile {
            tracker.killCommandFile()
        }
        
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
        NSWorkspace.shared.open(URL(string: helpURL)!)
    }

    
    // Function to either quit by hitting the Continue button of to show a EULA
    @IBAction func continueButton(_ sender: Any) {
        let conditional = agreementButton
        if conditional == true {
            do {
                let storyBoard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)  as NSStoryboard
                let myViewController = storyBoard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SheetViewController")) as! NSViewController
                self.presentViewControllerAsSheet(myViewController)

            }
        }
        else {
            //Write .DEPNotifyDone file to disk

            let DEPKey = true
            let EULAKey = false

            // Write Done File
            self.view.window?.close()
            let fileMgr = FileManager()
            let pathDone = "/Users/Shared/.DEPNotifyDone"
            fileMgr.createFile(atPath: pathDone, contents: nil, attributes: nil)

            // Set timestamp
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
            let dateInFormat = dateFormatter.string(from: Date())
            print (dateInFormat)

            // Write plist file
            let plistPath = "/Users/Shared/DEPNotify.plist"
            let dict : [String: Any] = [
                "DEPNotifyDone": DEPKey,
                "EULA Acceptance": EULAKey,
                "Onboarding Date": dateInFormat,
                // any other key values
            ]
            let someData = NSDictionary(dictionary: dict)
            let isWritten = someData.write(toFile: plistPath, atomically: true)
            print("is the file created: \(isWritten)")

            //NSApp.terminate(self)
            NSApp.terminate(nil)

        }
    }
    
    // Key pressing
    
    override func keyDown(with event: NSEvent) {
        
        switch event.modifierFlags.intersection(NSEvent.ModifierFlags.deviceIndependentFlagsMask) {
        case [NSEvent.ModifierFlags.command, NSEvent.ModifierFlags.control] where event.charactersIgnoringModifiers == quitKey:
            NSApp.terminate(nil)
        default:
            break
        }
    }
}

class WindowController: NSWindowController {
    
    override func windowDidLoad() {
        
        if CommandLine.arguments.contains("-fullScreen") {
            
            NSApp.activate(ignoringOtherApps: true)
            self.window?.makeKeyAndOrderFront(self)
            self.window?.center()
            self.window?.isMovable = false
            
            background = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Background")) as? Background
            background?.showWindow(self)
            background?.sendBack()
            NSApp.windows[0].level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        }
    }
}
