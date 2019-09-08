//
//  SheetViewController.swift
//  DEPNotify
//
//  Created by Federico Deis on 27/10/2017.
//  Copyright © 2018 AgileMobility360 LLC. All rights reserved.
//

import Foundation
import Cocoa

class RegistrationViewController: NSViewController, NSTextFieldDelegate, NSApplicationDelegate {
    
    // Interface Builder Connectors
    @IBOutlet var registrationView: NSView!
    
    // Registration Window: Image and Title
    @IBOutlet weak var mainImagePlaceholder: NSImageView!
    @IBOutlet weak var mainTitlePlaceholder: NSTextField!
    
    // Registration Window: Labels
    @IBOutlet weak var textField1Label: NSTextField!
    @IBOutlet weak var textField2Label: NSTextField!
    @IBOutlet weak var popupButton1Label: NSTextField!
    @IBOutlet weak var popupButton2Label: NSTextField!
    @IBOutlet weak var popupButton3Label: NSTextField!
    @IBOutlet weak var popupButton4Label: NSTextField!

    // Registration Window: Input and Contents
    @IBOutlet weak var textField1: NSTextField!
    @IBOutlet weak var textField2: NSTextField!
    
    @IBOutlet weak var popupButton1: NSPopUpButton!
    @IBOutlet weak var popupButton2: NSPopUpButton!
    @IBOutlet weak var popupButton3: NSPopUpButton!
    @IBOutlet weak var popupButton4: NSPopUpButton!
    
    // Check for valid regex pattern
    @IBOutlet weak var hasTextFieldValidPattern: NSTextField!
    

    // Check for sensitive information
    @IBOutlet weak var thisComputerStoresSensitiveInformation: NSButton!
    @IBOutlet weak var thisComputerStoresSensitiveInformationBuble: NSButton!
    
    // Registration Window: Required Input
    @IBOutlet weak var textField1Required: NSImageView!
    @IBOutlet weak var textField2Required: NSImageView!

    // Registration Window: Action Button
    @IBOutlet weak var continueActionButton: NSButton!
    
    // Information Bubbles
    @IBOutlet weak var textField1Bubble: NSButton!
    @IBOutlet weak var textField2Bubble: NSButton!
    @IBOutlet weak var popupMenu1Bubble: NSButton!
    @IBOutlet weak var popupMenu2Bubble: NSButton!
    @IBOutlet weak var popupMenu3Bubble: NSButton!
    @IBOutlet weak var popupMenu4Bubble: NSButton!
    
    
    // Global variables:
    
    var pathToPlistDefault = "/Users/Shared/UserInput.plist"
    var plistPath = ""
    var registrationImage: NSImage?
    var popupSegue = String()
    
    var contentToPass: [String] = []
    
    var myResult = false
    var securiryOptionsCounter = 0
    
    // Security Options Variables
    var securityOption1Key = "InfoSec - Sensitive Personal Information"
    var securityOption2Key = "InfoSec - Client Data"
    var securityOption3Key = "InfoSec - Government Regulated Data"
    var securityOption4Key = "InfoSec - FFIEC"
    var securityOption5Key = "InfoSec - HIPAA"
    var securityOption6Key = "InfoSec - PCI Data"
    var textField1RegexPattern = ""
    var textField2RegexPattern = ""
    var textField1LabelForRegex = ""
    var textField2LabelForRegex = ""
    var textField1Placeholder = ""
    var textField2Placeholder = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get path to user plist file
        if let pathToPlistFileValue = UserDefaults.standard.string(forKey: "pathToPlistFile"){
            plistPath = pathToPlistFileValue
        } else {
            plistPath = pathToPlistDefault
        }
        
        //
        // initialize the user input plist file
        //
        if FileManager.default.fileExists(atPath: plistPath) {
            let plistContent = NSMutableDictionary(contentsOfFile: plistPath)!
            plistContent.setValue(false, forKey: securityOption1Key)
            plistContent.setValue(false, forKey: securityOption2Key)
            plistContent.setValue(false, forKey: securityOption3Key)
            plistContent.setValue(false, forKey: securityOption4Key)
            plistContent.setValue(false, forKey: securityOption5Key)
            plistContent.setValue(false, forKey: securityOption6Key)
            plistContent.setValue(false, forKey: "StoresSecurityInformation")
            
            plistContent.write(toFile: plistPath, atomically: true)
             NSLog("Plist file has been updated")
        } else {
            let userInputDictionary : [String: Any] = [
                securityOption1Key: false,
                securityOption2Key: false,
                securityOption3Key: false,
                securityOption4Key: false,
                securityOption5Key: false,
                securityOption6Key: false,
                "StoresSecurityInformation": false,
                ]
            let dataToWrite = NSDictionary(dictionary: userInputDictionary)
            _ = dataToWrite.write(toFile: plistPath, atomically: true)
            NSLog("Plist file has been created")
            self.view.window?.close()
            
        }

        
        //
        // Customize Registration View Controller
        //
        
        // Set custom logo
        if let registerTitlePicturePath = UserDefaults.standard.string(forKey: "registrationPicturePath") {
            registrationImage = NSImage.init(byReferencingFile: registerTitlePicturePath)
            mainImagePlaceholder.image = registrationImage
            mainImagePlaceholder.imageScaling = .scaleProportionallyUpOrDown
            mainImagePlaceholder.imageAlignment = .alignCenter
        } else {
            NSLog("No Registation custom image found. Reverting to default image")
        }
        
        // Set button label
        if let registerButtonTitle = UserDefaults.standard.string(forKey: "registrationButtonLabel"){
            continueActionButton.title = registerButtonTitle
        } else {
            continueActionButton.title = "Register"
        }
        
        // Set Main title
        if let registerMainText = UserDefaults.standard.string(forKey: "registrationMainTitle"){
            mainTitlePlaceholder.stringValue = registerMainText
        } else {
            mainTitlePlaceholder.stringValue = "Register this Mac"
        }
        
        // Set Text field 1 label
        if let textField1LabelValue = UserDefaults.standard.string(forKey: "textField1Label") {
            textField1LabelForRegex = textField1LabelValue
            textField1Label.stringValue = textField1LabelValue
            textField1Label.isHidden = false
            textField1.isHidden = false
            NSLog("Displaying Registration Text Field 1")
            // Check for placeholder
            if let textField1LabelPlaceholderValue = UserDefaults.standard.string(forKey: "textField1Placeholder") {
                textField1.placeholderString = textField1LabelPlaceholderValue
                NSLog("Displaying Registration Text Field 1 placeholder")
            }
            // Check for bubble
            if UserDefaults.standard.object(forKey: "textField1Bubble") != nil {
                textField1Bubble.isHidden = false
                NSLog("Displaying Registration Text Field 1 bubble")
            }
        } else {
            NSLog("No Text Field 1 to load")
        }
        
        // TextField1RegexPattern
        if let textField1RegexPatternValue = UserDefaults.standard.string(forKey: "textField1RegexPattern") {
            textField1RegexPattern = textField1RegexPatternValue
            NSLog("Text Field Regex Pattern 1: \(textField1RegexPattern)")
        }

        // Set Text field 2 label
        if let textField2LabelValue = UserDefaults.standard.string(forKey: "textField2Label") {
            textField2LabelForRegex = textField2LabelValue
            textField2Label.stringValue = textField2LabelValue
            textField2Label.isHidden = false
            textField2.isHidden = false
            NSLog("Displaying Registration Text Field 2")
            // Check for placeholder
            if let textField2LabelPlaceholderValue = UserDefaults.standard.string(forKey: "textField2Placeholder") {
                textField2.placeholderString = textField2LabelPlaceholderValue
                NSLog("Displaying Registration Text Field 2 placeholder")
            }
            // Check for bubble
            if UserDefaults.standard.object(forKey: "textField2Bubble") != nil {
                textField2Bubble.isHidden = false
                NSLog("Displaying Registration Text Field 1 bubble")
            }
        } else {
            NSLog ("No Text Field 2 to load")
        }
    
        // TextField2RegexPattern
        if let textField2RegexPatternValue = UserDefaults.standard.string(forKey: "textField2RegexPattern") {
            textField2RegexPattern = textField2RegexPatternValue
            NSLog("Text Field Regex Pattern 2: \(textField2RegexPattern)")
        }
        
        // Set Button 1 label and contents
        if let popupButton1LabelValue = UserDefaults.standard.string(forKey: "popupButton1Label") {
            popupButton1Label.stringValue = popupButton1LabelValue
            popupButton1Label.isHidden = false
            popupButton1.isHidden = false
            if let popupButton1ContentValue = UserDefaults.standard.array(forKey: "popupButton1Content")  {
                popupButton1.removeAllItems()
                popupButton1.addItems(withTitles: popupButton1ContentValue as! [String])
                popupButton1.selectItem(at: 0)
                // Check for bubble
                if UserDefaults.standard.object(forKey: "popupMenu1Bubble") != nil {
                    popupMenu1Bubble.isHidden = false
                }
            } else {
                NSLog("No Popup Contents in Defaults")
                popupButton1.removeAllItems()
            }
        }
    
        // Set Button 2 label and contents
        if let popupButton2LabelValue = UserDefaults.standard.string(forKey: "popupButton2Label") {
            popupButton2Label.stringValue = popupButton2LabelValue
            popupButton2Label.isHidden = false
            popupButton2.isHidden = false
            if let popupButton2ContentValue = UserDefaults.standard.array(forKey: "popupButton2Content")  {
                popupButton2.removeAllItems()
                popupButton2.addItems(withTitles: popupButton2ContentValue as! [String])
                popupButton2.selectItem(at: 0)
                // Check for bubble
                if UserDefaults.standard.object(forKey: "popupMenu2Bubble") != nil {
                    popupMenu2Bubble.isHidden = false
                }
            } else {
                NSLog("No Popup Contents in Defaults")
                popupButton2.removeAllItems()
            }
        }
        
        // Set Button 3 label and contents
        if let popupButton3LabelValue = UserDefaults.standard.string(forKey: "popupButton3Label") {
            popupButton3Label.stringValue = popupButton3LabelValue
            popupButton3Label.isHidden = false
            popupButton3.isHidden = false
            if let popupButton3ContentValue = UserDefaults.standard.array(forKey: "popupButton3Content")  {
                popupButton3.removeAllItems()
                popupButton3.addItems(withTitles: popupButton3ContentValue as! [String])
                popupButton3.selectItem(at: 0)
                // Check for bubble
                if UserDefaults.standard.object(forKey: "popupMenu3Bubble") != nil {
                    popupMenu3Bubble.isHidden = false
                }
            } else {
                NSLog("No Popup Contents in Defaults")
                popupButton3.removeAllItems()
            }
        }
        
        // Set Button 4 label and contents
        if let popupButton4LabelValue = UserDefaults.standard.string(forKey: "popupButton4Label") {
            popupButton4Label.stringValue = popupButton4LabelValue
            popupButton4Label.isHidden = false
            popupButton4.isHidden = false
            if let popupButton4ContentValue = UserDefaults.standard.array(forKey: "popupButton4Content")  {
                popupButton4.removeAllItems()
                popupButton4.addItems(withTitles: popupButton4ContentValue as! [String])
                popupButton4.selectItem(at: 0)
                // Check for bubble
                if UserDefaults.standard.object(forKey: "popupMenu4Bubble") != nil {
                    popupMenu4Bubble.isHidden = false
                }
            } else {
                NSLog("No Popup Contents in Defaults")
                popupButton4.removeAllItems()
            }
        }
        
        let thisComputerStoresSensitiveInformationEnabled = UserDefaults.standard.bool(forKey: "enableSensitiveInformationOption")
        print(thisComputerStoresSensitiveInformationEnabled)
        
        if thisComputerStoresSensitiveInformationEnabled {
            thisComputerStoresSensitiveInformation.isHidden = false
            thisComputerStoresSensitiveInformationBuble.isHidden = false
        }
    }
    
    
    @IBAction func textField1BubbleAction(_ sender: Any) {
        let textField1ContentToPass = UserDefaults.standard.object(forKey: "textField1Bubble") as? [String] ?? [String]()
        contentToPass = textField1ContentToPass
        popupSegue = "textField1BubbleSegue"
        // Performe segue to Alert View Controller
        self.performSegue(withIdentifier: popupSegue, sender: self)
    }

    @IBAction func textField2BubbleAction(_ sender: Any) {
        let contentToPassArray = UserDefaults.standard.object(forKey: "textField2Bubble") as? [String] ?? [String]()
        contentToPass = contentToPassArray
        popupSegue = "textField2BubbleSegue"
        // Performe segue to Alert View Controller
        self.performSegue(withIdentifier: popupSegue, sender: self)
    }

    @IBAction func popupMenu1BubbleAction(_ sender: Any) {
        let contentToPassArray = UserDefaults.standard.object(forKey: "popupMenu1Bubble") as? [String] ?? [String]()
        contentToPass = contentToPassArray
        popupSegue = "popupMenu1BubbleSegue"
        // Performe segue to Alert View Controller
        self.performSegue(withIdentifier: popupSegue, sender: self)
    }
    
    @IBAction func popupMenu2BubbleAction(_ sender: Any) {
        let contentToPassArray = UserDefaults.standard.object(forKey: "popupMenu2Bubble") as? [String] ?? [String]()
        contentToPass = contentToPassArray
        popupSegue = "popupMenu2BubbleSegue"
        // Performe segue to Alert View Controller
        self.performSegue(withIdentifier: popupSegue, sender: self)
    }
   
    @IBAction func popupMenu3BubbleAction(_ sender: Any) {
        let contentToPassArray = UserDefaults.standard.object(forKey: "popupMenu3Bubble") as? [String] ?? [String]()
        contentToPass = contentToPassArray
        popupSegue = "popupMenu3BubbleSegue"
        // Performe segue to Alert View Controller
        self.performSegue(withIdentifier: popupSegue, sender: self)
    }
    
    @IBAction func popupMenu4BubbleAction(_ sender: Any) {
        let contentToPassArray = UserDefaults.standard.object(forKey: "popupMenu4Bubble") as? [String] ?? [String]()
        contentToPass = contentToPassArray
        popupSegue = "popupMenu4BubbleSegue"
        // Performe segue to Alert View Controller
        self.performSegue(withIdentifier: popupSegue, sender: self)
    }
    
    // Actions: Sensitive Information Action
    @IBAction func sensitiveInformationBubbleAction(_ sender: Any) {
        contentToPass = ["SomethingDummyToPass"]
        popupSegue = "sensitiveInformationBubbleSegue"
        // Performe segue to Alert View Controller
        self.performSegue(withIdentifier: popupSegue, sender: self)
    }
    
    @IBAction func sensitiveInformationCheckboxAction(_ sender: Any) {
        switch thisComputerStoresSensitiveInformation.state {
        case .on:
            writePlistFile(securityKeyValue: "StoresSecurityInformation", securityChoiceValue: true)
            contentToPass = ["true"]
            popupSegue = "sensitiveInformationBubbleSegue"
            // Performe segue to Alert View Controller
            self.performSegue(withIdentifier: popupSegue, sender: self)
        case .off:
            // Set security options state to false
            writePlistFile(securityKeyValue: "StoresSecurityInformation", securityChoiceValue: false)
            //setSecurityOptionsToZero()
        default: break
        }
    }
    
    
    // Action: Close registration window and write user input data to UserInput plist file
    @IBAction func registationCompleteAction(_ sender: Any) {
        // First check if the user input fields are completed as required
        checkTextInputFields()
    }
    
    // Checks for Empty Text Fields, If Empty an Error Message Will be Displayed
    func checkTextInputFields() {
        
        // Set Field Required Indicator to Hidden
        textField1Required.isHidden = true
        textField2Required.isHidden = true
        hasTextFieldValidPattern.isHidden = true
        
        
        // Check if Text Fields are mandatory
        let TextField1IsOptional = UserDefaults.standard.bool(forKey: "textField1IsOptional")
        let TextField2IsOptional = UserDefaults.standard.bool(forKey: "textField2IsOptional")
        
        // Get NSTextField Values as Strings
        let textField1Value = textField1.stringValue
        let textField2Value = textField2.stringValue
        
        print("Text Field Regex Pattern 1: \(textField1RegexPattern)")
        
        // Turn on mandatory fields indicator
        if textField1Value.isEmpty && !textField1.isHidden && !TextField1IsOptional {
            do {
                textField1Required.isHidden = false
                NSSound.beep()
               
                NSLog("Text Field 1 is empty")
            }
        } else if textField2Value.isEmpty && !textField2.isHidden && !TextField2IsOptional {
            do {
                textField2Required.isHidden = false
                NSSound.beep()
                
                NSLog("Text Field 2 is empty")
            }
        } else if !textField1RegexPattern.isEmpty && !checkRegexPattern(regexPattern: textField1RegexPattern, textToValidate: textField1Value) {
            hasTextFieldValidPattern.stringValue = "\(textField1LabelForRegex) is not the correct format"
            hasTextFieldValidPattern.isHidden = false
            NSSound.beep()
            
            NSLog("Text Field 1 does not match pattern")
            
         
        } else if !textField2RegexPattern.isEmpty && !checkRegexPattern(regexPattern: textField2RegexPattern, textToValidate: textField2Value) {
            hasTextFieldValidPattern.stringValue = "\(textField2LabelForRegex) is not the correct format"
            hasTextFieldValidPattern.isHidden = false
            NSSound.beep()
            
            NSLog("Text Field 2 does not match pattern")
       
        
        } else {
                
            // Write user input content to UserInput plist file
            writeContentsToPlistFile()
            
            // Write registration bom file to disk
            writeBomFile()
            
            // Close registration window and return to DEPNotify main window
            self.view.window?.close()
        }
    }
    
    
    // Function to pass data to Alert View Controller
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if (segue.identifier! == popupSegue) {
            if let myViewController = segue.destinationController as? PopupRegistrationViewController {
                let datatoPass = contentToPass
                myViewController.messagePass = datatoPass
            }
        }
    }

    
    // Use Regex to control character input in text fields
    func controlTextDidChange(_ obj: Notification) {
        
        // Check DEPNotify defaults to get upper and lower input fields regex
       
        if let textField1Regex = UserDefaults.standard.string(forKey: "TextField1CharValidation") {
            let textField1CharacterSet: CharacterSet = CharacterSet(charactersIn: textField1Regex).inverted
            self.textField1.stringValue = (self.textField1.stringValue.components(separatedBy: textField1CharacterSet) as NSArray).componentsJoined(by: "")
            textField1Required.isHidden = true
        } else {
            let textField1CharacterSet: CharacterSet = CharacterSet(charactersIn: "@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789-_. ").inverted
            self.textField1.stringValue = (self.textField1.stringValue.components(separatedBy: textField1CharacterSet) as NSArray).componentsJoined(by: "")
            textField1Required.isHidden = true
            hasTextFieldValidPattern.isHidden = true

        }

        if let textField2Regex = UserDefaults.standard.string(forKey: "TextField2CharValidation") {
            let textField2CharacterSet: CharacterSet = CharacterSet(charactersIn: textField2Regex).inverted
            self.textField2.stringValue = (self.textField2.stringValue.components(separatedBy: textField2CharacterSet) as NSArray).componentsJoined(by: "")
            textField2Required.isHidden = true
        } else {
            let textField2CharacterSet: CharacterSet = CharacterSet(charactersIn: "@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789-_. ").inverted
            self.textField2.stringValue = (self.textField2.stringValue.components(separatedBy: textField2CharacterSet) as NSArray).componentsJoined(by: "")
            textField2Required.isHidden = true
            hasTextFieldValidPattern.isHidden = true
        }
        
    }
    
    // Write Registration done bom file to disk
    func writeBomFile() {

        // Path to write the bom file
        let bomFile = "/var/tmp/com.depnotify.registration.done"

        // Touching bom file
        do {
            FileManager.default.createFile(atPath: bomFile, contents: nil, attributes: nil)
            NSLog("BOM file created")
        }
    }

    func setSecurityOptionsToZero() {
        
            NSLog("Resetting options at: \(plistPath)")
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
            NSLog("Resetting Security Options @\(dataWritten)")
        
    }
    
    func checkRegexPattern(regexPattern: String, textToValidate: String) -> Bool {
        var returnValue = true
        
        do {
            let regex = try NSRegularExpression(pattern: regexPattern)
            let nsString = textToValidate as NSString
            let results = regex.matches(in: textToValidate, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            NSLog("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    func getSystemUUID() -> String? {
        let dev = IOServiceMatching("IOPlatformExpertDevice")
        let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, dev)
        let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformUUIDKey as CFString, kCFAllocatorDefault, 0)
        IOObjectRelease(platformExpert)
        let ser: CFTypeRef = serialNumberAsCFString!.takeUnretainedValue()
        if let result = ser as? String {
            return result
        }
        return nil
    }
    
    func getSystemSerial() -> String? {
        let dev = IOServiceMatching("IOPlatformExpertDevice")
        let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, dev)
        let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0)
        IOObjectRelease(platformExpert)
        let ser: CFTypeRef = serialNumberAsCFString!.takeUnretainedValue()
        if let result = ser as? String {
            return result
        }
        return nil
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
    
    // Function: Writes security options state to UserInput.plist file
    func writePlistFile(securityKeyValue: String, securityChoiceValue: Bool) {
        if FileManager.default.fileExists(atPath: plistPath) {
            let plistContent = NSMutableDictionary(contentsOfFile: plistPath)!
            plistContent.setValue(securityChoiceValue, forKey: securityKeyValue)
            plistContent.write(toFile: plistPath, atomically: true)
            NSLog("Created Key: \(securityKeyValue) with \(securityChoiceValue)")
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
    
    //
    // This function saves user input data and selections to UserInput plist file
    //
    func writeContentsToPlistFile() {
        // Get NSTextField Values as Strings
        let textField1Value = textField1.stringValue
        let textField2Value = textField2.stringValue
        let popupButton1Value = popupButton1.title
        let popupButton2Value = popupButton2.title
        let popupButton3Value = popupButton3.title
        let popupButton4Value = popupButton4.title
        
        if readPlistFile(securityKeyValue: "StoresSecurityInformation") {
            NSLog("Go ahead")
        } else {
            setSecurityOptionsToZero()
        }
        
        let systemUUIDValue = getSystemUUID()
        let systemSerialValue = getSystemSerial()

        // Set timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let LastRegistrationDate = dateFormatter.string(from: Date())
        NSLog(LastRegistrationDate)

        // Set Plist Domain Keys
        let textField1Key = textField1Label.stringValue
        let textField2Key = textField2Label.stringValue
        let popupButton1Key = popupButton1Label.stringValue
        let popupButton2Key = popupButton2Label.stringValue
        let popupButton3Key = popupButton3Label.stringValue
        let popupButton4Key = popupButton4Label.stringValue

        // Check if Plist file exits
        if FileManager.default.fileExists(atPath: plistPath) {
            let plistContent = NSMutableDictionary(contentsOfFile: plistPath)!
            
            if UserDefaults.standard.string(forKey: "textField1Label") != nil {
                plistContent.setValue(textField1Value, forKey: textField1Key) }
            if UserDefaults.standard.string(forKey: "textField2Label") != nil {
                plistContent.setValue(textField2Value, forKey: textField2Key)}
            if UserDefaults.standard.string(forKey: "popupButton1Label") != nil {
                plistContent.setValue(popupButton1Value, forKey: popupButton1Key)}
            if UserDefaults.standard.string(forKey: "popupButton2Label") != nil {
                plistContent.setValue(popupButton2Value, forKey: popupButton2Key)}
            if UserDefaults.standard.string(forKey: "popupButton3Label") != nil {
                plistContent.setValue(popupButton3Value, forKey: popupButton3Key)}
            if UserDefaults.standard.string(forKey: "popupButton4Label") != nil {
                plistContent.setValue(popupButton4Value, forKey: popupButton4Key)}
            
            plistContent.setValue(systemSerialValue!, forKey: "Computer Serial")
            plistContent.setValue(systemUUIDValue!, forKey: "Computer UUID")
            plistContent.setValue(LastRegistrationDate, forKey: "Registration Date")

            plistContent.write(toFile: plistPath, atomically: true)
            NSLog("Is Plist file created: Yes")
        }

        else {

            let userInputDictionary : [String: Any] = [
                textField1Key: textField1Value,
                textField2Key: textField2Value,
                popupButton1Key: popupButton1Value,
                popupButton2Key: popupButton2Value,
                popupButton3Key: popupButton3Value,
                popupButton4Key: popupButton4Value,
                "Computer Serial": systemSerialValue!,
                "Computer UUID": systemUUIDValue!,
                "Registration Date": LastRegistrationDate,

                ]
            let dataToWrite = NSDictionary(dictionary: userInputDictionary)
            let dataWritten = dataToWrite.write(toFile: plistPath, atomically: true)
            NSLog("Is Plist file created: \(dataWritten)")
        }
    }
    
    
}
