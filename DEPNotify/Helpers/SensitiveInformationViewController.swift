//
//  SensitiveInformationViewController.swift
//  DEPNotify
//
//  Created by Federico Deis on 31/10/2018.
//  Copyright © 2018 AgileMobility360. All rights reserved.
//

import Foundation
import Cocoa

class SensitiveInformationViewController: NSViewController, NSTextFieldDelegate, NSApplicationDelegate {
    
    @IBOutlet weak var securityOption1: NSButton!
    @IBOutlet weak var securityOption2: NSButton!
    @IBOutlet weak var securityOption3: NSButton!
    @IBOutlet weak var securityOption4: NSButton!
    @IBOutlet weak var securityOption5: NSButton!
    @IBOutlet weak var securityOption6: NSButton!
    
    var securityOption1Key = "InfoSec - Sensitive Personal Information"
    var securityOption2Key = "InfoSec - Client Data"
    var securityOption3Key = "InfoSec - Government Regulated Data"
    var securityOption4Key = "InfoSec - FFIEC"
    var securityOption5Key = "InfoSec - HIPAA"
    var securityOption6Key = "InfoSec - PCI Data"
    
    
    
    // Message from Registration
    var messagePass = [String]()
    
    // Set Data Compliance Checkbox State
    var buttonState: Bool?
    
    var pathToPlistDefault = "/Users/Shared/UserInput.plist"
    var plistPath = ""
    var myResult = false
    var valueToReturn = false
    
    override func viewDidLoad() {
        
        // Get path to user plist file
        if let pathToPlistFileValue = UserDefaults.standard.string(forKey: "pathToPlistFile"){
            plistPath = pathToPlistFileValue
        } else {
            plistPath = pathToPlistDefault
        }
        
        // Enable/Disable Security Options based on state of Sensitive Information checkbox
        let storeSecurityInformationValue = readPlistFile(securityKeyValue: "StoresSecurityInformation")
        NSLog("Value: \(storeSecurityInformationValue)")
        if storeSecurityInformationValue == false {
            NSLog("Stores Security Information: false")
            disableSecurityOptions()
            //setStoreSensitiveInformationValuesToFalse()
        } else if storeSecurityInformationValue == true {
            NSLog("Stores Security Information: true")
            enableSecurityOptions()
        }
        
        //
        // Read On/Off state from UserInput plist file
        //
        let optionResults1 = readPlistFile(securityKeyValue:securityOption1Key)
        let option1 = optionResults1 as Bool
        if option1 == true {
            securityOption1.state = .on
        } else {
            securityOption1.state = .off
        }
        
        let optionResults2 = readPlistFile(securityKeyValue:securityOption2Key)
        let option2 = optionResults2 as Bool
        if option2 == true {
            securityOption2.state = .on
        } else {
            securityOption2.state = .off
        }

        let optionResults3 = readPlistFile(securityKeyValue:securityOption3Key)
        let option3 = optionResults3 as Bool
        if option3 == true {
            securityOption3.state = .on
        } else {
            securityOption3.state = .off
        }
        
        let optionResults4 = readPlistFile(securityKeyValue:securityOption4Key)
        let option4 = optionResults4 as Bool
        if option4 == true {
            securityOption4.state = .on
        } else {
            securityOption4.state = .off
        }
        
        let optionResults5 = readPlistFile(securityKeyValue:securityOption5Key)
        let option5 = optionResults5 as Bool
        if option5 == true {
            securityOption5.state = .on
        } else {
            securityOption5.state = .off
        }
        
        let optionResults6 = readPlistFile(securityKeyValue:securityOption6Key)
        let option6 = optionResults6 as Bool
        if option6 == true {
            securityOption6.state = .on
        } else {
            securityOption6.state = .off
        }
        
    }
    
    @IBAction func option1Button(_ sender: Any) {
        switch securityOption1.state {
        case .on:
            let buttonState = true
            writePlistFile(securityKeyValue: securityOption1Key, securityChoiceValue: buttonState)
            NSLog("Option Button 1 on")
        case .off:
            let buttonState = false
            writePlistFile(securityKeyValue: securityOption1Key, securityChoiceValue: buttonState)
            NSLog("Option Button 1 off")
        default: break
        }
    }

    @IBAction func option2Button(_ sender: Any) {
        switch securityOption2.state {
        case .on:
            let buttonState = true
            writePlistFile(securityKeyValue: securityOption2Key, securityChoiceValue: buttonState)
            NSLog("Option Button 2 on")
        case .off:
            let buttonState = false
            writePlistFile(securityKeyValue: securityOption2Key, securityChoiceValue: buttonState)
            NSLog("Option Button 2 off")
        default: break
        }
    }
    
    @IBAction func option3Button(_ sender: Any) {
        switch securityOption3.state {
        case .on:
            let buttonState = true
            writePlistFile(securityKeyValue: securityOption3Key, securityChoiceValue: buttonState)
            NSLog("Option Button 3 on")
        case .off:
            let buttonState = false
            writePlistFile(securityKeyValue: securityOption3Key, securityChoiceValue: buttonState)
            NSLog("Option Button 3 off")
        default: break
        }
    }
    
    @IBAction func option4Button(_ sender: Any) {
        switch securityOption4.state {
        case .on:
            let buttonState = true
            writePlistFile(securityKeyValue: securityOption4Key, securityChoiceValue: buttonState)
            NSLog("Option Button 4 on")
        case .off:
            let buttonState = false
            writePlistFile(securityKeyValue: securityOption4Key, securityChoiceValue: buttonState)
            NSLog("Option Button 5 off")
        default: break
        }
    }
    
    @IBAction func option5Button(_ sender: Any) {
        switch securityOption5.state {
        case .on:
            let buttonState = true
            writePlistFile(securityKeyValue: securityOption5Key, securityChoiceValue: buttonState)
            NSLog("Option Button 6 on")
        case .off:
            let buttonState = false
            writePlistFile(securityKeyValue: securityOption5Key, securityChoiceValue: buttonState)
            NSLog("Option Button 6 off")
        default: break
        }
    }
    
    @IBAction func option6Button(_ sender: Any) {
        switch securityOption6.state {
        case .on:
            let buttonState = true
            writePlistFile(securityKeyValue: securityOption6Key, securityChoiceValue: buttonState)
            NSLog("Option Button on")
        case .off:
            let buttonState = false
            writePlistFile(securityKeyValue: securityOption6Key, securityChoiceValue: buttonState)
            NSLog("Option Button off")
        default: break
        }
    }
    
    
    //
    // View Controller Global Functions
    //
    
    // Function: Writes security options state to UserInput.plist file
    func writePlistFile(securityKeyValue: String, securityChoiceValue: Bool) {
        if FileManager.default.fileExists(atPath: plistPath) {
                        let plistContent = NSMutableDictionary(contentsOfFile: plistPath)!
                        plistContent.setValue(securityChoiceValue, forKey: securityKeyValue)
                        plistContent.write(toFile: plistPath, atomically: true)
            NSLog("Created Key: \(securityKeyValue)")
                    }
                    else {
                        let userInputDictionary : [String: Any] = [
                            securityKeyValue: securityChoiceValue,
                            ]
            let dataToWrite = NSDictionary(dictionary: userInputDictionary)
            let dataWritten = dataToWrite.write(toFile: plistPath, atomically: true)
            NSLog("Is Plist file created: \(dataWritten)")
            
        }
    }

    // Function: Reads security options state to UserInput.plist file
    func readPlistFile(securityKeyValue: String) -> Bool {
        var format = PropertyListSerialization.PropertyListFormat.xml //format of the property list
        var plistData:[String:AnyObject] = [:]  //our data
        let plistXML = FileManager.default.contents(atPath: plistPath)! //the data in XML format
        do{ //convert the data to a dictionary and handle errors.
            plistData = try PropertyListSerialization.propertyList(from: plistXML,options: .mutableContainersAndLeaves,format: &format)as! [String:AnyObject]
            //assign the values in the dictionary to the properties
            myResult = plistData[securityKeyValue] as! Bool
        }
        catch { // error condition
            NSLog("Error reading plist: \(error), format: \(format)")
            }
        return myResult
    }
    
    func enableSecurityOptions() {
        NSLog("Enabling checkboxes")
        securityOption1.isEnabled = true
        securityOption2.isEnabled = true
        securityOption3.isEnabled = true
        securityOption4.isEnabled = true
        securityOption5.isEnabled = true
        securityOption6.isEnabled = true
    }
    
    func disableSecurityOptions() {
        NSLog("Disabling checkboxes")
        securityOption1.isEnabled = false
        securityOption2.isEnabled = false
        securityOption3.isEnabled = false
        securityOption4.isEnabled = false
        securityOption5.isEnabled = false
        securityOption6.isEnabled = false
    }
    
    func setStoreSensitiveInformationValuesToFalse() {
        let userInputDictionary : [String: Any] = [
            securityOption1Key: false,
            securityOption2Key: false,
            securityOption3Key: false,
            securityOption4Key: false,
            securityOption5Key: false,
            securityOption6Key: false,
            ]
        let dataToWrite = NSDictionary(dictionary: userInputDictionary)
        let dataWritten = dataToWrite.write(toFile: plistPath, atomically: true)
        NSLog("Is Plist file created: \(dataWritten)")
    }
}
