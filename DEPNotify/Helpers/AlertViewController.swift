//
//  Alert.swift
//  DEPNotify
//
//  Created by Federico Deis on 31/10/2018.
//  Copyright © 2018 AgileMobility360. All rights reserved.
//

import Foundation
import Cocoa

class AlertViewController: NSViewController, NSTextFieldDelegate, NSApplicationDelegate {
    
    @IBOutlet weak var quitButton: NSButton!
    @IBOutlet weak var alertMessageBox: NSTextField!

    // Set global variable
    var messagePass = String()
    var alertType: String = ""
    var alertMessage: String = ""
    
   override func viewDidLoad() {

    alertType = messagePass.components(separatedBy: " ").first!
    
    switch alertType {
    case "Quit:" :
        alertMessage = messagePass.replacingOccurrences(of: "Quit: ", with: "")
        alertType = "Quit"
        quitButton.title = "Quit"
    case "Logout:" :
        alertMessage = messagePass.replacingOccurrences(of: "Logout: ", with: "")
        alertType = "Logout"
        quitButton.title = "Logout"
    default: break
    }
    
    // Set dialog box text content based on user input from Command: Quit:
    alertMessageBox.stringValue = alertMessage
    
    
    }

    @IBAction func quitButton(_ sender: Any) {
        if alertType == "Quit" {
        self.view.window?.close()
        NSApp.terminate(self)
        } else if alertType == "Logout" {
            self.quitSession()
            NSApp.terminate(self)
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
        
    }


}
