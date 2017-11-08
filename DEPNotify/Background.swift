//
//  background.swift
//  DEPNotify
//
//  Created by Joel Rennich on 5/2/17.
//  Copyright © 2017 Orchard & Grove Inc. All rights reserved.
//

import Foundation
import Cocoa

class Background: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        if let backgroundWindow = self.window {
            let mainDisplayRect = NSScreen.main()?.frame
            backgroundWindow.contentRect(forFrameRect: mainDisplayRect!)
            backgroundWindow.setFrame((NSScreen.main()?.frame)!, display: true)
            backgroundWindow.setFrameOrigin((NSScreen.main()?.frame.origin)!)
            backgroundWindow.level = Int(CGWindowLevelForKey(.maximumWindow) - 1 )
        }
    }

    func sendBack() {
        self.window?.orderBack(self)
        print("going back")
    }
    
}
