//
//  DynamicMenuView.swift
//  DEPNotify
//
//  Created by Joel Rennich on 6/9/21.
//  Copyright © 2021 Orchard & Grove. All rights reserved.
//

import Foundation
import SwiftUI
import AppKit

@available(macOS 11, *)
enum EntryObjectTypes {
    case text, textField, secureText, pullDown, toggle
}

@available(macOS 11, *)
struct EntryObject: Identifiable {
    let id = UUID().uuidString
    let type: EntryObjectTypes
    let title: String
    var value: String = ""
    var tag: String
    var items = [String]()
}

@available(macOS 11, *)
struct FormField : View {
    @State private var output: String = ""
    let title: String
    var didUpdateText: (String) -> ()
    var body: some View {
        VStack {
            TextField(title, text: $output)
                .onChange(of: output, perform: { fieldValue in
                    self.didUpdateText(self.output)
                })
        }
    }
}

@available(macOS 11, *)
struct SecureFormField : View {
    @State private var output: String = ""
    let title: String
    var didUpdateText: (String) -> ()
    var body: some View {
        VStack {
            SecureField(title, text: $output)
                .onChange(of: output, perform: { fieldValue in
                    self.didUpdateText(self.output)
                })
        }
    }
}

@available(macOS 11, *)
struct PullDownFormField : View {
    @State private var output: String = ""
    let title: String
    let items: [String]
    var didUpdateText: (String) -> ()
    var body: some View {
        VStack {
            Picker(title, selection: $output, content: {
                ForEach(items, id: \.self, content: { i in
                    Text(i)
                })
            })
                .onChange(of: output, perform: { i in
                    self.didUpdateText(i)
                })
        }
    }
}

@available(macOS 11, *)
struct ToggleButton: View {
    @State private var output: Bool = false
    let title: String
    var didUpdateText: (String) -> ()
    var body: some View {
        HStack {
            Toggle(title, isOn: $output)
            .toggleStyle(SwitchToggleStyle(tint: .blue))
            .onChange(of: output, perform: { i in
                self.didUpdateText(String(i))
            })
        }
    }
}

@available(macOS 11, *)
class FormModel: ObservableObject {
    @Published var entries = [EntryObject]()
    var results = [String:String]()
    
    init() {
        if let menuSettings = UserDefaults.standard.array(forKey: "CustomMenus") as? [[String:AnyObject]] {
            for menu in menuSettings {
                guard let type = menu["Type"] as? String else { continue }
                guard let title = menu["Title"] as? String else { continue }
                guard let tag = menu["Tag"] as? String else { continue }
                switch type {
                case "Text":
                    let newEntry = EntryObject(type: .text, title: title, tag: tag)
                    entries.append(newEntry)
                case "TextField":
                    let newEntry = EntryObject(type: .textField, title: title, tag: tag)
                    entries.append(newEntry)
                case "SecureTextField":
                    let newEntry = EntryObject(type: .secureText, title: title, tag: tag)
                    entries.append(newEntry)
                case "Toggle":
                    let newEntry = EntryObject(type: .toggle, title: title, tag: tag)
                    entries.append(newEntry)
                default:
                    let items = menu["Items"] as? [String] ?? [String]()
                    let newEntry = EntryObject(type: .pullDown, title: title, tag: tag, items: items)
                    entries.append(newEntry)
                }
            }
        }
    }
}

@available(macOS 11, *)
struct DynamicMenuView: View {
    @ObservedObject var model = FormModel()
    @State var fieldNumber: String = ""
    @Binding var parent: NSViewController?

    var body: some View {
        getImage()
            .resizable()
            .scaledToFit()
            .frame(minWidth: 200, idealWidth: 500, maxWidth: 900, minHeight: 200, idealHeight: nil, maxHeight: 500, alignment: .center)
            .padding()
        if let registerMainText = UserDefaults.standard.string(forKey: "registrationMainTitle"){
            Text(registerMainText)
                .font(.largeTitle)
                .bold()
                .padding()
        } else {
            Text("Register this Mac")
                .font(.largeTitle)
                .bold()
                .padding()
        }
        VStack{
        ScrollView {
        VStack {
            ForEach(model.entries) { i in
                if i.type == .textField {
                    HStack {
                        Text(i.title)
                        FormField(title: "") { (output) in
                            model.results[i.tag] = output
                        }
                    }
                    .padding([.leading, .trailing])
                } else if i.type == .secureText {
                    HStack {
                        Text(i.title)
                        SecureFormField(title: "") { (output) in
                            model.results[i.tag] = output
                        }
                    }
                    .padding([.leading, .trailing])
                } else if i.type == .pullDown {
                    HStack {
                    PullDownFormField(title: i.title, items: i.items, didUpdateText: { (output) in
                        model.results[i.tag] = output
                    })
                    }
                        .padding([.leading, .trailing])
                } else if i.type == .toggle {
                    HStack {
                        ToggleButton(title: i.title, didUpdateText: { (output) in
                            model.results[i.tag] = output
                        })
                        }
                            .padding([.leading, .trailing])
                } else {
                    HStack {
                        Text(i.title)
                    }
                    .padding()
                }
        }
        Button(action: {
            writeBomFile()
            writeOutAnswers()
            self.parent?.dismiss(nil)
        }) { Text("Done")}
        .padding()
        Spacer()
        }
        }
        }
        .frame(minWidth: 600, idealWidth: 600, maxWidth: 900, minHeight: 200, idealHeight: nil, maxHeight: 900, alignment: .center)

        Spacer()
    }
    
    func getImage() -> Image {
        if let registerTitlePicturePath = UserDefaults.standard.string(forKey: "registrationPicturePath") {
            if let registrationImage = NSImage.init(byReferencingFile: registerTitlePicturePath) {
                return Image(nsImage: registrationImage)
            }
        } else {
            NSLog("No Registation custom image found. Reverting to default image")
        }
        return Image("mbpWhiteTick")
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
    
    func writeOutAnswers() {
        
        let systemUUIDValue = getSystemUUID()
        let systemSerialValue = getSystemSerial()

        // Set timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let LastRegistrationDate = dateFormatter.string(from: Date())
        
        var results = model.results
        results["LastRegistrationDate"] = LastRegistrationDate
        results["Serial"] = getSystemSerial()
        results["UUID"] = getSystemUUID()
        let path = UserDefaults.standard.object(forKey: "pathToPlistFile") as? String ?? "/Users/Shared/UserInput.json"
        let encoder = JSONEncoder()
        if let json = try? encoder.encode(results),
           let jsonString = String(data: json, encoding: .utf8) {
            do {
                try jsonString.write(toFile: path, atomically: true, encoding: .utf8)
            } catch {
                print(error)
            }
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
}

@available(macOS 11, *)
class
DynamicViewController: NSHostingController<DynamicMenuView>
{
    @objc
    required
    dynamic
    init() {
        weak var parent: NSViewController? = nil // avoid reference cycling
        super.init(rootView: DynamicMenuView(parent: Binding(
            get: { parent },
            set: { parent = $0 })
        ))
        parent = self // self usage not allowed till super.init
    }
    
    required init?(coder: NSCoder)
    {
        weak var parent: NSViewController? = nil // avoid reference cycling
        super.init(coder: coder, rootView:
            DynamicMenuView(parent: Binding(
                get: { parent },
                set: { parent = $0 })
            )
        )

        parent = self // self usage not allowed till super.init
    }
}
