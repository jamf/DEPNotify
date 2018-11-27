//
//  Help.swift
//  DEPNotify
//
//  Created by Federico Deis on 8/10/18.
//  Copyright © 2018 AgileMobility360 LLC. All rights reserved.
//

import Foundation
import Cocoa

class HelpViewController: NSViewController, NSTextFieldDelegate, NSApplicationDelegate {
    
    @IBOutlet weak var helpTitle: NSTextField!
    @IBOutlet weak var helpContent: NSTextField!
    
    // Set default help body text
    let defaultContent = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas tincidunt ex at lectus pretium, a gravida mi iaculis. Donec neque nisi, sollicitudin at metus at, viverra blandit diam. Nullam pharetra feugiat lacus, eu faucibus justo aliquet vel. \n \n Nunc euismod rhoncus purus, vitae imperdiet magna eleifend eget. In ac bibendum elit, eget finibus lectus. Integer tincidunt malesuada neque, id auctor erat lacinia non. Nunc venenatis quam at
"""

    override func viewDidLoad() {
        
        // Look for content in preferences file
        if let getTitle = UserDefaults.standard.string(forKey: "helpBubbleTitle"){
            print ("Help title found in preferences file. Loading it.")
            helpTitle.stringValue = getTitle
        } else {
            print ("No Help Title in Preferences file, turning to defaults")
            helpTitle.stringValue = "Need any help?"
        }
        
        // Get the EULA Subtitle Window from Preferences file
        if let getContent = UserDefaults.standard.string(forKey: "helpBubbleBody"){
            print ("Help content found in preferences file. Loading it.")
            helpContent.stringValue = getContent
        } else {
            print ("No Help Content in Preferences file. turning to defaults")
            helpContent.stringValue = defaultContent
        }
    }
}
