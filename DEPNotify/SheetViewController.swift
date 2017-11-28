//
//  SheetViewController.swift
//  DEPNotify
//
//  Created by Federico Deis on 27/10/2017.
//  Copyright © 2017 Trusource Labs. All rights reserved.
//

import Foundation
import Cocoa

class SheetViewController: NSViewController {

    @IBOutlet weak var AgreeButton: NSButton!
    @IBOutlet weak var BackButton: NSButton!
    @IBOutlet var EULATextView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let expandedPath = "/var/tmp/eula.txt"

        do {
            // Get the contents
            let eula = try NSString(contentsOfFile: expandedPath, encoding: String.Encoding.utf8.rawValue)
            print(eula)
            //EULATextView .insertText(contents)
            EULATextView.string = eula as String
        }
        catch let error as NSError {
            print("No terms file found: \(error)")
        }

    }

    @IBAction func agreeEULA(_ sender: Any) {

        let DEPKey = true
        let EULAKey = true

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
