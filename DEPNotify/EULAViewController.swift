//
//  UELA.swift
//  DEPNotify
//
//  Created by Federico Deis on 06/04/2018.
//  Copyright © 2018 AgileMobility360 LLC. All rights reserved.
//

import Cocoa
import Foundation

class EULAViewController: NSViewController {

    // Interface Builder Connnectors
    @IBOutlet weak var eulaTitle: NSTextField!
    @IBOutlet weak var eulaSubTitle: NSTextField!
    @IBOutlet var eulaContent: NSTextView!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var continueButton: NSButton!
    @IBOutlet weak var agreeCheck: NSButton!
    
    var pathToPlistDefault = "/Users/Shared/UserInput.plist"
    var plistPath = ""
    
    let defaultEULA = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas tincidunt ex at lectus pretium, a gravida mi iaculis. Donec neque nisi, sollicitudin at metus at, viverra blandit diam. Nullam pharetra feugiat lacus, eu faucibus justo aliquet vel. Nunc euismod rhoncus purus, vitae imperdiet magna eleifend eget. In ac bibendum elit, eget finibus lectus. Integer tincidunt malesuada neque, id auctor erat lacinia non. Nunc venenatis quam at ornare cursus. Cras in eros rhoncus, imperdiet odio varius, imperdiet dolor. Aenean convallis tempor maximus. Pellentesque at ipsum turpis.

Fusce aliquet tortor in nibh ullamcorper facilisis. Proin nec erat vitae purus consequat ultricies. Aliquam porttitor metus at urna dignissim, nec ultrices magna hendrerit. Donec dictum tortor sed magna vestibulum fringilla. Curabitur nec consequat libero, id lobortis turpis. Curabitur at ante erat. Fusce ut risus varius, semper purus at, aliquet dolor. Nullam neque metus, euismod sed arcu a, porta venenatis mauris. Maecenas sollicitudin tortor id arcu dictum placerat. Morbi vitae porta urna.

Sed convallis volutpat aliquam. Fusce eu aliquam metus. Donec quis sollicitudin erat, eu tincidunt libero. Donec aliquet ut turpis sed rhoncus. Sed pharetra hendrerit tellus, ut tempus metus. Curabitur purus est, congue vel volutpat at, gravida at purus. Curabitur sit amet leo sed velit feugiat dignissim sit amet at nisl. Etiam egestas consequat ultricies. Maecenas facilisis ultrices elit, quis vehicula metus volutpat non. Sed auctor orci at molestie dictum.

Suspendisse nec velit sed magna auctor accumsan ac eget nisi. Integer consectetur ultricies luctus. Fusce iaculis non lorem eget feugiat. Aenean mattis, sem quis consectetur feugiat, odio orci egestas massa, eu dignissim diam leo eu sem. Curabitur ut ex nisl. Phasellus varius felis ut felis placerat molestie vitae nec metus. Aliquam a dictum arcu, eu cursus magna. Aliquam dapibus placerat iaculis. Fusce sed justo urna. Fusce enim ipsum, volutpat in mauris ac, porta varius orci. Vivamus rutrum consectetur purus eget laoreet. Donec ut justo leo. Quisque id dolor dapibus, sodales enim at, accumsan eros.

Ut molestie arcu ligula, et porttitor ex facilisis dapibus. Vivamus molestie lectus ut tempor condimentum. Nullam ullamcorper metus sit amet hendrerit varius. Interdum et malesuada fames ac ante ipsum primis in faucibus. Vestibulum erat quam, posuere ac sollicitudin nec, rhoncus ac ipsum. Donec quis nulla est. In semper porta orci lacinia efficitur. Duis libero est, pharetra id sapien euismod, convallis condimentum massa. Sed tellus urna, lobortis sit amet nunc a, feugiat auctor lorem. Sed mattis, tellus non ultrices sodales, metus arcu lacinia ipsum, id dignissim arcu odio nec neque. Aenean a nunc sit amet massa malesuada rutrum id non sem. Praesent non luctus magna. Sed ultrices lacinia sodales. Aenean mattis blandit ex, eget egestas ligula aliquam eget.
"""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get path to user plist file
        if let pathToPlistFileValue = UserDefaults.standard.string(forKey: "pathToPlistFile"){
            plistPath = pathToPlistFileValue
        } else {
            plistPath = pathToPlistDefault
        }
        
        // Get EULA texts from Preferences file
        if let pathToEULA = UserDefaults.standard.string(forKey: "pathToEULA") {
            
            // Get eula file extension
            let fileExtension = NSURL(fileURLWithPath: pathToEULA).pathExtension
            
            // Check if eula file exists
            if FileManager.default.fileExists(atPath: pathToEULA) {
            
                do {
                // Get Plain Text Contents
                if fileExtension == "txt" {
                    let eula = try NSString(contentsOfFile: pathToEULA, encoding: String.Encoding.utf8.rawValue)
                    NSLog(pathToEULA)
                    eulaContent.string = eula as String
                
                // Get Rich Text Contents
                } else if fileExtension == "rtf" {
                    // Get the contents
                    let eula = NSMutableAttributedString(path: pathToEULA, documentAttributes: nil)
                    NSLog(pathToEULA)
                    eulaContent.textStorage?.setAttributedString(eula!)

                }
            }
            catch let error as NSError {
                NSLog("No terms file found: \(error)")
                eulaContent.string = defaultEULA
            }
            
        } else {
            // set the EULA text to a placeholder
            eulaContent.string = defaultEULA
        }
        }
        
        // Get the EULA Main Title Window from Preferences file
        if let EULAMainTitle = UserDefaults.standard.string(forKey: "EULAMainTitle"){
            eulaTitle.stringValue = EULAMainTitle
        } else {
            NSLog("No EULA Title in Preferences file")
        }
        
        // Get the EULA Subtitle Window from Preferences file
        if let EULASubTitle = UserDefaults.standard.string(forKey: "EULASubTitle"){
            eulaSubTitle.stringValue = EULASubTitle
        } else {
            NSLog("No EULA Subtitle in Preferences file")
        }
    }

    func writeBomFile() {
        let bomFile = "/var/tmp/com.depnotify.agreement.done"
        // Create Registration complete bom file
        do {
            FileManager.default.createFile(atPath: bomFile, contents: nil, attributes: nil)
            NSLog("BOM file create")
        }
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
    

    //
    // Button Functions
    //
    
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
        NotificationCenter.default.post(name: enableContinueButton, object: self)
        self.view.window?.close()
    }
    
    @IBAction func continueButtonAction(_ sender: Any) {
        // EULA Domain Keys
        let eulaDomainKey = "EULA Agreed"
        
        // Get EULA Acceptance
        let userHasAgreedToEULA = true
        
        // Get System wide UUID and Serial Number
        let systemUUIDValue = getSystemUUID()
        let systemSerialValue = getSystemSerial()
        
        // Get current time and date to create a timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let LastRegistrationDate = dateFormatter.string(from: Date())
        NSLog(LastRegistrationDate)
        
        
        // If User input plist file exists append content
        if FileManager.default.fileExists(atPath: plistPath) {
            let plistContent = NSMutableDictionary(contentsOfFile: plistPath)!
            
            plistContent.setValue(userHasAgreedToEULA, forKey: eulaDomainKey)
            plistContent.setValue(systemSerialValue!, forKey: "Computer Serial")
            plistContent.setValue(systemUUIDValue!, forKey: "Computer UUID")
            plistContent.setValue(LastRegistrationDate, forKey: "Registration Date")
            
            plistContent.write(toFile: plistPath, atomically: true)
            NSLog("Is Plist file created: Yes")
            writeBomFile()
            self.view.window?.close()
        }
            
        else {
            // Else create a new user input plist file
            let userInputDictionary : [String: Any] = [
                eulaDomainKey: userHasAgreedToEULA,
                "Computer Serial": systemSerialValue!,
                "Computer UUID": systemUUIDValue!,
                "Registration Date": LastRegistrationDate,
                ]
            let dataToWrite = NSDictionary(dictionary: userInputDictionary)
            let dataWritten = dataToWrite.write(toFile: plistPath, atomically: true)
            NSLog("Is Plist file created: \(dataWritten)")
            writeBomFile()
            self.view.window?.close()
        }
     
    }
    
}
