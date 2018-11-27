//
//  ViewController.swift
//  DEPNotify
//
//  Created by Joel Rennich on 2/16/17.
//  Copyright © 2017 Orchard & Grove Inc. All rights reserved.
//
//  Continue Button, Video, Image and Web modifications added by Federico Deis, Slack: @fgd
//  FileVault Alert icon and dialog modifications added by Federico Deis, Slack: @fgd
//  Bom files added by Federico Deis, Slack: @fgd

import Cocoa
import Foundation
import WebKit
import AVKit
import AVFoundation


private var statusContext = 0
private var commandContext = 1

var background: Background?

var enableContinueButton =  NSNotification.Name(rawValue: "menu.nomad.DEPNotify.reenableContinue")
var resetContinueButonActionValue = NSNotification.Name(rawValue: "menu.nomad.DEPNotify.resetContinue")

var buttonAction = ""
var conditional = ""

var alertMessage = ""
var contentToPass = ""

class ViewController: NSViewController, WKNavigationDelegate, NSApplicationDelegate {
    

    @IBOutlet weak var MainTitle: NSTextField!
    @IBOutlet weak var MainText: NSTextField!
    @IBOutlet weak var ProgressBar: NSProgressIndicator!
    @IBOutlet weak var StatusText: NSTextField!
    @IBOutlet weak var LogoCell: NSImageCell!
    @IBOutlet weak var ImageCell: NSImageCell!
    @IBOutlet var myView: NSView!
    @IBOutlet weak var helpButton: NSButton!
    @IBOutlet weak var continueButton: NSButton!
    @IBOutlet weak var logoView: NSImageView!
    @IBOutlet weak var ImageView: NSImageView!
    
    var tracker = TrackProgress()
    
    var helpURL = String()
    
    var determinate = false
    var totalItems: Double = 0
    var currentItem = 0
    
    var notify = false
    
    var logo: NSImage?
    var maintextImage: NSImage?
    var notificationImage: NSImage?
    var fileVaultAlertIcon = NSImage(named: NSImage.Name(rawValue: "FileVault"))
    
    // Preparing the web view
    let wkWebView = WKWebView(frame: CGRect(x: 0, y: 122, width: 700, height: 328))
    var myRequest = ""
    
    // Preparing the video view
    let myVideoPlayerView = AVPlayerView(frame: CGRect(x: 0, y: 122, width: 700, height: 328)  )
    
    // Video file URL
    var pathToVideo = "/var/tmp/sample.mp4"
    
    @IBOutlet weak var test: NSImageView!
    
    var activateEachStep = false
    
    var killCommandFile = false
    
    var quitKey = "x"
    
    let myWorkQueue = DispatchQueue(label: "menu.nomad.DEPNotify.background_work_queue", attributes: [])
    
    var pathToPlistDefault = "/Users/Shared/UserInput.plist"
    var plistPath = ""
    
    // Variables to set Continue Button action
    var continueButtonTitle = "Continue" // Label of the continue button
    var buttonAction = "" // Variable for the action of the continue button

    // Variablet to set Status Text alignment
    var defaultStatusTextAlignment = "center"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // notification listeners
        NotificationCenter.default.addObserver(self, selector: #selector(enableContinue), name: enableContinueButton, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetContinueButtonActionVariable), name: resetContinueButonActionValue, object: nil)
        
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
        
        // Initialize UserInput plist file
        iniPlistFile()
        continueButton.title = continueButtonTitle
        
        // Set Status Text Alignment
        StatusText.alignment = .center
        if let statusTextAlignmentValue = UserDefaults.standard.string( forKey: "statusTextAlignment") {
            do {
                if statusTextAlignmentValue == "left" {
                    StatusText.alignment = .left
                } else if statusTextAlignmentValue == "center" {
                    StatusText.alignment = .center
                } else if statusTextAlignmentValue == "right" {
                    StatusText.alignment = .right
                }
            }
        }
        
        
        // Check if Help Buble Title is present, otherwise hide help button
        if let getHelpBubbleTitle = UserDefaults.standard.string(forKey: "helpBubbleTitle"){
            print ("Help title found in preferences file. Loading it.")
            helpButton.isHidden = false
        } else {
            helpButton.isHidden = true
        }
        
    }
    
    override func viewDidAppear() {
        
        // Set Dark Mode safe Main Window background color to white
        self.view.window?.backgroundColor = NSColor.controlBackgroundColor
        
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
                buttonAction = ""
                processCommand(command: newValue as! String)
            } else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
            
        }
    }
    
    func processCommand(command: String) {
        
        switch command.components(separatedBy: " ").first! {
        
        case "Video:" :
            let videoURL = command.replacingOccurrences(of: "Video: ", with: "")
            if (videoURL.hasPrefix("http")) { // If the URL provided is HTTP then stream
                self.view.addSubview(myVideoPlayerView)
                let myURL = URL(string: videoURL)
                let myPlayer = AVPlayer(url: myURL!)
                myVideoPlayerView.player = myPlayer
                myVideoPlayerView.controlsStyle = AVPlayerViewControlsStyle.none
                // Loop Video
                NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: myPlayer.currentItem, queue: nil)
                { notification in
                    let timer = CMTimeMake(5, 100);
                    myPlayer.seek(to: timer)
                    self.myVideoPlayerView.player?.play()
                }
                myVideoPlayerView.player?.play()
                
            } else { // if the URL is local then load
                self.view.addSubview(myVideoPlayerView)
                let myURL = NSURL(fileURLWithPath: videoURL)
                let myPlayer = AVPlayer(url: myURL as URL)
                myVideoPlayerView.player = myPlayer
                myVideoPlayerView.controlsStyle = AVPlayerViewControlsStyle.none
                // Loop Video
                NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: myPlayer.currentItem, queue: nil)
                { notification in
                    let timer = CMTimeMake(5, 100);
                    myPlayer.seek(to: timer)
                    self.myVideoPlayerView.player?.play()
                }
                myVideoPlayerView.player?.play()
            }

        case "YouTube:" :
            let youTubeID = command.replacingOccurrences(of: "YouTube: ", with: "")
            self.view.addSubview(wkWebView)
            let youtubeURL = URL(string: "https://www.youtube.com/embed/\(youTubeID)?autoplay=1&controls=0&showinfo=0")
            //let myURL = URL(string: youtubeURL!)
            let myRequest = URLRequest(url: youtubeURL!)
            wkWebView.load(myRequest)
            
        case "Website:" :
            let webSiteURL = command.replacingOccurrences(of: "Website: ", with: "")
            self.view.addSubview(wkWebView)
            
            wkWebView.allowsBackForwardNavigationGestures = false
            let myURL = URL(string:webSiteURL)
            let myRequest = URLRequest(url: myURL!)
            wkWebView.load(myRequest)
            
        case "FileVault:" :
            let alertController = NSAlert()
            alertController.icon = fileVaultAlertIcon
            alertController.messageText = command.replacingOccurrences(of: "FileVault: ", with: "")
            alertController.addButton(withTitle: "Ok")
            alertController.beginSheetModal(for: NSApp.windows[0])
            
        case "Alert:" :
            let alertController = NSAlert()
            alertController.messageText = command.replacingOccurrences(of: "Alert: ", with: "")
            alertController.addButton(withTitle: "Ok")
            alertController.beginSheetModal(for: NSApp.windows[0])
            
        // Puts a Button at the bottom of the window to Quit DEPNotify
        case "ContinueButton:" :
            let continueButtonTitle = command.replacingOccurrences(of: "ContinueButton: ", with: "")
            continueButton.title = continueButtonTitle
            //continueButton.isHighlighted = true
            continueButton.isHidden = false
            buttonAction = "Continue"
        
        // Puts a Button at the bottom of the window to display a Registration panel
        case "ContinueButtonRegister:" :
            let continueButtonTitle = command.replacingOccurrences(of: "ContinueButtonRegister: ", with: "")
            continueButton.title = continueButtonTitle
            continueButton.isHidden = false
            //continueButton.isHighlighted = true
            buttonAction = "Register"
            
        // Puts a Button at the bottom of the window to display an EULA panel
        case "ContinueButtonEULA:" :
            let continueButtonTitle = command.replacingOccurrences(of: "ContinueButtonEULA: ", with: "")
            continueButton.title = continueButtonTitle
            continueButton.isHidden = false
            //continueButton.isHighlighted = true
            buttonAction  = "EULA"
        
        // Puts a Button at the bottom of the window to restart the Mac
        case "ContinueButtonRestart:" :
            let continueButtonTitle = command.replacingOccurrences(of: "ContinueButtonRestart: ", with: "")
            continueButton.title = continueButtonTitle
            continueButton.isHidden = false
            //continueButton.isHighlighted = true
            buttonAction = "Restart"

        // Puts a Button at the bottom of the window to logout from the Mac
        case "ContinueButtonLogout:" :
            let continueButtonTitle = command.replacingOccurrences(of: "ContinueButtonLogout: ", with: "")
            continueButton.title = continueButtonTitle
            continueButton.isHidden = false
            //continueButton.isHighlighted = true
            buttonAction = "Logout"

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
            ProgressBar.increment(by: Double(stepMove))
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
            
            logoView.image = logo
            logoView.imageScaling = .scaleProportionallyUpOrDown
            logoView.imageAlignment = .alignCenter
            //LogoCell.image = logo
            //LogoCell.imageScaling = .scaleProportionallyUpOrDown
            //LogoCell.imageAlignment = .alignCenter
            
        case "KillCommandFile:" :
            killCommandFile = true
            
        case "Logout:":
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
            MainText.isHidden = false
            MainTitle.isHidden = false
            logoView.isHidden = false

            // Need to do two replacingOccurrences since we are replacing with different values
            let newlinecommand = command.replacingOccurrences(of: "\\n", with: "\n")
            MainText.stringValue = newlinecommand.replacingOccurrences(of: "MainText: ", with: "")
            
            // Unload Subviews
            wkWebView.stopLoading(myRequest)
            wkWebView.removeFromSuperview()
            self.myVideoPlayerView.player?.pause()
            myVideoPlayerView.removeFromSuperview()
            
            
            
            // Remove the image if there is one
            ImageCell.image = nil
            //ImageCell.image = NSImage.init(byReferencingFile: "")
            
        case "MainTextImage:" :
            maintextImage = NSImage.init(byReferencingFile: command.replacingOccurrences(of: "MainTextImage: ", with: ""))
            
            ImageView.image = maintextImage
            ImageView.imageScaling = .scaleProportionallyUpOrDown
            ImageView.imageAlignment = .alignCenter
            
            // Unload Subviews
            wkWebView.stopLoading(myRequest)
            wkWebView.removeFromSuperview()
            self.myVideoPlayerView.player?.pause()
            myVideoPlayerView.removeFromSuperview()
            
            MainText.isHidden = true
            //MainTitle.isHidden = true
            //logoView.isHidden = true
            
        case "MainTitle:" :
            // Need to do two replacingOccurrences since we are replacing with different values
            let newlinecommand = command.replacingOccurrences(of: "\\n", with: "\n")
            MainTitle.stringValue = newlinecommand.replacingOccurrences(of: "MainTitle: ", with: "")
            ImageCell.image = NSImage.init(byReferencingFile: "")
            
            // Unload Web subview
            wkWebView.stopLoading(myRequest)
            wkWebView.removeFromSuperview()
            self.myVideoPlayerView.player?.pause()
            myVideoPlayerView.removeFromSuperview()
            
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
            alertMessage = command.replacingOccurrences(of: "Quit: ", with: "")
            contentToPass = alertMessage

            // Performe segue to Alert View Controller
            self.performSegue(withIdentifier: NSStoryboard.SegueIdentifier(rawValue: "alertSegue"), sender: self)

        
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
        
        _ = AECreateDesc(
            UInt32(typeProcessSerialNumber),
            &psn,
            MemoryLayout<ProcessSerialNumber>.size,
            &targetDesc
        )
        
        _ = AECreateAppleEvent(
            UInt32(kCoreEventClass),
            kAEReallyLogOut,
            &targetDesc,
            AEReturnID(kAutoGenerateReturnID),
            AETransactionID(kAnyTransactionID),
            &eventToSend
        )
        
        AEDisposeDesc(&targetDesc)
        
        _ = AESendMessage(
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
        
        _ = AECreateDesc(
            UInt32(typeProcessSerialNumber),
            &psn,
            MemoryLayout<ProcessSerialNumber>.size,
            &targetDesc
        )
        
        _ = AECreateAppleEvent(
            UInt32(kCoreEventClass),
            kAERestart,
            &targetDesc,
            AEReturnID(kAutoGenerateReturnID),
            AETransactionID(kAnyTransactionID),
            &eventToSend
        )
        
        AEDisposeDesc(&targetDesc)
        
        _ = AESendMessage(
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

    // Init User input Plist file
    func iniPlistFile() {
       // Check the Path to the Plist File is already defined in preferences
        if let pathToPlistFileValue = UserDefaults.standard.string(forKey: "pathToPlistFile"){
            plistPath = pathToPlistFileValue
        } else {
            plistPath = pathToPlistDefault
        }
        // If Plist File exists, erase it
        if FileManager.default.fileExists(atPath: plistPath) {
            do {
                    try FileManager.default.removeItem(atPath: plistPath)
                print("Removing plist file")
            }
        catch {
            print ("Error: No Plist File to Initialize")
            print (plistPath)
            
            }
        }
    }
    
    //MARK: Notification actions
    
    @objc func enableContinue() {
        //continueButton.isHighlighted = true
        continueButton.isEnabled = true
        continueButton.isHidden = false
        continueButton.setNextState()
    }

    @objc func resetContinueButtonActionVariable() {
        //Reset Continue Button Action
        buttonAction = ""
        print ("Reseting ContinueButtonAction")
    }
    
    @IBAction func HelpClick(_ sender: Any) {
        // HelpClick will not display a pop up window customized
        // via DEPNotify preferences file
        //NSWorkspace.shared.open(URL(string: helpURL)!) //Uncomment this line to call help URL
    }

    
    // Continue Button Actions
    
    @IBAction func continueButton(_ sender: NSButton) {
        
        let conditional = buttonAction // Set a conditional based on the continue button action sent by the user
        print ("Conditonal: \(conditional)")
        continueButton.isHidden = true // Hide Continue Button
        
        // Start switch matching to display the correct window
        switch conditional {
        case "Register" :
                let storyBoard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)  as NSStoryboard
                let myViewController = storyBoard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "RegistrationViewController")) as! NSViewController
                self.presentViewControllerAsSheet(myViewController)
        case "EULA" :
                let storyBoard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)  as NSStoryboard
                let myViewController = storyBoard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "EULAViewController")) as! NSViewController
                self.presentViewControllerAsSheet(myViewController)
        case "Restart" :
                let bomFile = "/var/tmp/com.depnotify.provisioning.restart"
                FileManager.default.createFile(atPath: bomFile, contents: nil, attributes: nil)
                print ("BOM file create")
                self.reboot()
                NSApp.terminate(self)
        case "Logout" :
                let bomFile = "/var/tmp/com.depnotify.provisioning.logout"
                FileManager.default.createFile(atPath: bomFile, contents: nil, attributes: nil)
                print ("BOM file create")
                self.quitSession()
        default :
                let bomFile = "/var/tmp/com.depnotify.provisioning.done"
                FileManager.default.createFile(atPath: bomFile, contents: nil, attributes: nil)
                print ("BOM file create")
                NSApp.terminate(self)
        }
    }
    
    // Key pressing
    
    override func keyDown(with event: NSEvent) {
        
        switch event.modifierFlags.intersection(NSEvent.ModifierFlags.deviceIndependentFlagsMask) {
        case [NSEvent.ModifierFlags.command, NSEvent.ModifierFlags.control] where event.charactersIgnoringModifiers == "quitKey":
            NSApp.terminate(nil)
        default:
            break
        }
    }

    // Function to pass data to Alert View Controller
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if (segue.identifier!.rawValue == "alertSegue") {
            if let myViewController = segue.destinationController as? AlertViewController {
                let datatoPass = contentToPass
                myViewController.messagePass = datatoPass
            }
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
