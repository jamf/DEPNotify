//
//  UELA.swift
//  DEPNotify
//
//  Created by Federico Deis on 06/04/2018.
//  Copyright © 2018 AgileMobility360. All rights reserved.
//

import Cocoa
import Foundation

class EULA: NSViewController {

    // Interface Builder Connnectors
    @IBOutlet weak var eulaTitle: NSTextField!
    @IBOutlet weak var eulaSubTitle: NSTextField!
    @IBOutlet var eulaContent: NSTextView!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var continueButton: NSButton!
    @IBOutlet weak var agreeCheck: NSButton!

    var PathToPlistDefault = "/Users/Shared/DEPNotify.plist"
    var plistPath = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set window background color to white
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = CGColor.white
        
        // Get EULA text from Preferences file
        if let pathToEULA = UserDefaults.standard.string(forKey: "pathToEULA"){
            do {
                // Get the contents
                let eula = try NSString(contentsOfFile: pathToEULA, encoding: String.Encoding.utf8.rawValue)
                print(pathToEULA)
                //EULATextView .insertText(contents)
                eulaContent.string = eula as String
            }
            catch let error as NSError {
                print("No terms file found: \(error)")
                eulaContent.string = "Lorem Ipsum"
            }

        }
    }

    func writeBomFile() {
        let bomFile = "/var/tmp/com.depnotify.agreement.done"
        // Create Registration complete bom file
        do {
            FileManager.default.createFile(atPath: bomFile, contents: nil, attributes: nil)
            print ("BOM file create")
        }
    }
    
    @IBAction func agreeButton(_ sender: Any) {
        if continueButton.isEnabled == false {
            do {
                continueButton.isEnabled = true}
        }
        else {
            continueButton.isEnabled = false
        }
     
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
                self.view.window?.close()
    }
    
    @IBAction func continueButtonAction(_ sender: Any) {
        if let PathToPlistFileValue = UserDefaults.standard.string(forKey: "PathToPlistFile"){
            plistPath = "\(PathToPlistFileValue)DEPNotify.plist"
        } else {
             plistPath = PathToPlistDefault
        }
        
        if FileManager.default.fileExists(atPath: plistPath) {
            let plistContent = NSMutableDictionary(contentsOfFile: plistPath)!
            plistContent.setValue(true, forKey: "EULA Agreed")
            plistContent.write(toFile: plistPath, atomically: true)
            print("Is Plist file created: Yes")
            writeBomFile()
            self.view.window?.close()
        }
        else {
            
            let dict : [String: Any] = [
                "EULA Agreed": true,
                ]
            let someData = NSDictionary(dictionary: dict)
            let isWritten = someData.write(toFile: plistPath, atomically: true)
            print("Is Plist file created: \(isWritten)")
            writeBomFile()
            self.view.window?.close()
        }
    }
    
}
