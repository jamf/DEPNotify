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
    
   override func viewDidLoad() {
    // Set dialog box text content based on user input from Command: Quit:
    alertMessageBox.stringValue = messagePass
    }

    @IBAction func quitButton(_ sender: Any) {
        self.view.window?.close()
        NSApp.terminate(self)
    }
}
