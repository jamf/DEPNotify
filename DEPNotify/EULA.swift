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
    
    let defaultEULA = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas tincidunt ex at lectus pretium, a gravida mi iaculis. Donec neque nisi, sollicitudin at metus at, viverra blandit diam. Nullam pharetra feugiat lacus, eu faucibus justo aliquet vel. Nunc euismod rhoncus purus, vitae imperdiet magna eleifend eget. In ac bibendum elit, eget finibus lectus. Integer tincidunt malesuada neque, id auctor erat lacinia non. Nunc venenatis quam at ornare cursus. Cras in eros rhoncus, imperdiet odio varius, imperdiet dolor. Aenean convallis tempor maximus. Pellentesque at ipsum turpis.

Fusce aliquet tortor in nibh ullamcorper facilisis. Proin nec erat vitae purus consequat ultricies. Aliquam porttitor metus at urna dignissim, nec ultrices magna hendrerit. Donec dictum tortor sed magna vestibulum fringilla. Curabitur nec consequat libero, id lobortis turpis. Curabitur at ante erat. Fusce ut risus varius, semper purus at, aliquet dolor. Nullam neque metus, euismod sed arcu a, porta venenatis mauris. Maecenas sollicitudin tortor id arcu dictum placerat. Morbi vitae porta urna.

Sed convallis volutpat aliquam. Fusce eu aliquam metus. Donec quis sollicitudin erat, eu tincidunt libero. Donec aliquet ut turpis sed rhoncus. Sed pharetra hendrerit tellus, ut tempus metus. Curabitur purus est, congue vel volutpat at, gravida at purus. Curabitur sit amet leo sed velit feugiat dignissim sit amet at nisl. Etiam egestas consequat ultricies. Maecenas facilisis ultrices elit, quis vehicula metus volutpat non. Sed auctor orci at molestie dictum.

Suspendisse nec velit sed magna auctor accumsan ac eget nisi. Integer consectetur ultricies luctus. Fusce iaculis non lorem eget feugiat. Aenean mattis, sem quis consectetur feugiat, odio orci egestas massa, eu dignissim diam leo eu sem. Curabitur ut ex nisl. Phasellus varius felis ut felis placerat molestie vitae nec metus. Aliquam a dictum arcu, eu cursus magna. Aliquam dapibus placerat iaculis. Fusce sed justo urna. Fusce enim ipsum, volutpat in mauris ac, porta varius orci. Vivamus rutrum consectetur purus eget laoreet. Donec ut justo leo. Quisque id dolor dapibus, sodales enim at, accumsan eros.

Ut molestie arcu ligula, et porttitor ex facilisis dapibus. Vivamus molestie lectus ut tempor condimentum. Nullam ullamcorper metus sit amet hendrerit varius. Interdum et malesuada fames ac ante ipsum primis in faucibus. Vestibulum erat quam, posuere ac sollicitudin nec, rhoncus ac ipsum. Donec quis nulla est. In semper porta orci lacinia efficitur. Duis libero est, pharetra id sapien euismod, convallis condimentum massa. Sed tellus urna, lobortis sit amet nunc a, feugiat auctor lorem. Sed mattis, tellus non ultrices sodales, metus arcu lacinia ipsum, id dignissim arcu odio nec neque. Aenean a nunc sit amet massa malesuada rutrum id non sem. Praesent non luctus magna. Sed ultrices lacinia sodales. Aenean mattis blandit ex, eget egestas ligula aliquam eget.
"""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set window background color to white
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = CGColor.white
        
        // Get EULA text from Preferences file
        if let pathToEULA = UserDefaults.standard.string(forKey: "pathToEULA") {
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

        } else {
            // set the EULA text to a placeholder
            
            eulaContent.string = defaultEULA
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
        NotificationCenter.default.post(name: enableContinueButton, object: self)
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
            if UserDefaults.standard.bool(forKey: "quitSuccessiveEULA") {
                NSApp.terminate(self)
            }

        }
    }
    
}
