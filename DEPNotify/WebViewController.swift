//
//  WebViewController.swift
//  DEPNotify
//
//  Created by jcadmin on 11/11/20.
//  Copyright © 2020 Trusource Labs. All rights reserved.
//

import Foundation
import Cocoa
import WebKit

@available(macOS 10.12, *)
class WebViewController: NSViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var doneButton: NSButton!
    var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL.init(string: urlString ?? "https://www.apple.com") {
            webView.load(URLRequest.init(url: url))
        }
    }
    
    @IBAction func clickDone(_ sender: Any) {
        writeBomFile()
        self.view.window?.close()
    }
    
    func writeBomFile() {
        let bomFile = "/var/tmp/com.depnotify.webview.done"
        // Create Registration complete bom file
        do {
            FileManager.default.createFile(atPath: bomFile, contents: nil, attributes: nil)
            NSLog("WebView BOM file create")
        }
    }
}
