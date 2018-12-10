//
//  File.swift
//  DEPNotify
//
//  Created by Federico Deis on 31/10/2018.
//  Copyright © 2018 AgileMobility360. All rights reserved.
//

import Foundation
import Cocoa


class PopupRegistrationViewController: NSViewController, NSTextFieldDelegate, NSApplicationDelegate {

    @IBOutlet weak var informationTitle: NSTextField!
    @IBOutlet weak var informationContent: NSTextField!

        var messagePass = [String]()
    
    override func viewDidLoad() {
        informationTitle.stringValue = messagePass[0]
        informationContent.stringValue = messagePass[1]
    }



}
