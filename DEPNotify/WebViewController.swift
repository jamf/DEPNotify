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
import SecurityInterface.SFChooseIdentityPanel

@available(macOS 10.12, *)
class WebViewController: NSViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var doneButton: NSButton!
    var urlString: String?
    var panel: SFChooseIdentityPanel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL.init(string: urlString ?? "https://www.apple.com") {
            webView.navigationDelegate = self
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

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        print("Challenge received...")
        
        switch challenge.protectionSpace.authenticationMethod {
        case NSURLAuthenticationMethodNTLM:
            print("Request for NTLM authentication")
            completionHandler(.performDefaultHandling, nil)
        case NSURLAuthenticationMethodNegotiate:
            print("Request for Kerberos authentication")
            completionHandler(.performDefaultHandling, nil)
        case NSURLAuthenticationMethodClientCertificate:
            print("Request for client certificate")
            if let url = webView.url?.absoluteString as CFString?,
            let idPref = SecIdentityCopyPreferred(url, nil, nil) {
                let credential = URLCredential.init(identity: idPref, certificates: nil, persistence: .forSession)
                completionHandler(.useCredential, credential)
            } else if let identity = pickCert() {
                let credential = URLCredential.init(identity: identity, certificates: nil, persistence: .forSession)
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.performDefaultHandling, nil)
            }
        case NSURLAuthenticationMethodServerTrust:
            print("Request for server trust")
            completionHandler(.performDefaultHandling, nil)
        default:
            print("Unknown auth request")
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

extension WebViewController {
    
    func pickCert() -> SecIdentity? {
        panel = SFChooseIdentityPanel.shared()
        
        var searchReturn: AnyObject? = nil
        
        let identitySearchDict: [String:AnyObject] = [
            kSecClass as String: kSecClassIdentity,
            kSecReturnRef as String: true as AnyObject,
            kSecMatchLimit as String : kSecMatchLimitAll as AnyObject
        ]
        
        let err = SecItemCopyMatching(identitySearchDict as CFDictionary, &searchReturn)
        if searchReturn != nil && err == 0 {
            let identities = searchReturn as! [SecIdentity]
            var certs = [SecCertificate]()

            for id in identities {
                var myCert: SecCertificate?
                SecIdentityCopyCertificate(id, &myCert)
                if myCert != nil {
                    certs.append(myCert!)
                }
            }
            
            panel?.setAlternateButtonTitle("cancel")
            panel?.runModal(forIdentities: identities, message: "Choose wisely...")
            if let identity = panel?.identity() {
                return identity.takeRetainedValue()
            }
        }
        return nil
    }
}
