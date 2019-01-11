//
//  VerifyApplication.swift
//  Verify
//
//  Created by Joel Rennich on 11/10/18.
//  Copyright © 2018 Joel Rennich. All rights reserved.
//

import Cocoa
import os.log

@objc protocol UndoActionRespondable {
    func undo(_ sender: AnyObject)
}

@objc protocol RedoActionRespondable {
    func redo(_ sender: AnyObject)
}

class NotifyApplication : NSApplication {
    
    fileprivate let commandKey = NSEvent.ModifierFlags.command.rawValue
    fileprivate let commandShiftKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue
        
    override init() {
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Covers undo, redo, copy, paste and such if we need it
    // this is here because we don't have a menu in the main nib file
    
    override func sendEvent(_ event: NSEvent) {
        if event.type == NSEvent.EventType.keyDown {
            if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue == commandKey) {
                switch event.charactersIgnoringModifiers!.lowercased() {
                case "x":
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to:nil, from:self) { return }
                case "c":
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to:nil, from:self) { return }
                case "v":
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to:nil, from:self) { return }
                case "z":
                    if NSApp.sendAction(#selector(UndoActionRespondable.undo(_:)), to:nil, from:self) { return }
                case "a":
                    if NSApp.sendAction(#selector(NSText.selectAll(_:)), to:nil, from:self) { return }
                case "w":
                    //NSApp.keyWindow?.close()
                    break
                default:
                    break
                }
            }
            else if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue == commandShiftKey) {
                if event.charactersIgnoringModifiers == "Z" {
                    if NSApp.sendAction(#selector(RedoActionRespondable.redo(_:)), to:nil, from:self) { return }
                }
            }
        }
        super.sendEvent(event)
    }
}
