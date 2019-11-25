//
//  ViewController.swift
//  AppSigner
//
//  Created by Daniel Radtke on 11/2/15.
//  Copyright © 2015 Daniel Radtke. All rights reserved.
//

import Cocoa
import PromiseKit

class MainView: NSView, URLSessionDataDelegate, URLSessionDelegate, URLSessionDownloadDelegate {
    
    private var configuration: APIConfiguration?
    private var provider: APIProvider?

    //MARK: IBOutlets
    @IBOutlet var openSignerViewButton: NSButton!
    @IBOutlet var signerModeTipField: NSTextField!
    @IBOutlet var superSignDataView: NSView!
    @IBOutlet var issuerIDField: NSTextField!
    @IBOutlet var privateKeyField: NSTextField!
    @IBOutlet var privateKeyIDField: NSTextField!
    @IBOutlet var UDIDsField: NSTextField!
    @IBOutlet var ProvisioningProfilesPopup: NSPopUpButton!
    @IBOutlet var CodesigningCertsPopup: NSPopUpButton!
    @IBOutlet var StatusLabel: NSTextField!
    @IBOutlet var InputFileText: NSTextField!
    @IBOutlet var BrowseButton: NSButton!
    @IBOutlet var StartButton: NSButton!
    @IBOutlet var NewApplicationIDTextField: NSTextField!
    @IBOutlet var downloadProgress: NSProgressIndicator!
    @IBOutlet var appDisplayName: NSTextField!
    @IBOutlet var appShortVersion: NSTextField!
    @IBOutlet var appVersion: NSTextField!
    @IBOutlet var channelName: NSTextField!
    @IBOutlet var generalPlistButton: NSButton!
    @IBOutlet var outputAssetsButton: NSButton!
    @IBOutlet var ReplaceIconField: NSTextField!
    @IBOutlet var ReplaceIconChooseButton: NSButton!
    
    //MARK: Variables
    var provisioningProfiles:[ProvisioningProfile] = []
    var codesigningCerts: [String] = []
    //下载的证书路径
    var signingCertificate: String?
    var profileFilename: String?
    var ReEnableNewApplicationID = false
    var PreviousNewApplicationID = ""
    var outputFile: String?
    var startSize: CGFloat?
    var NibLoaded = false
    var inputFiles: [String] = []
    
    //MARK: Constants
    let defaults = UserDefaults()
    let fileManager = FileManager.default
    let bundleID = Bundle.main.bundleIdentifier
    let arPath = "/usr/bin/ar"
    let mktempPath = "/usr/bin/mktemp"
    let tarPath = "/usr/bin/tar"
    let unzipPath = "/usr/bin/unzip"
    let zipPath = "/usr/bin/zip"
    let defaultsPath = "/usr/bin/defaults"
    let codesignPath = "/usr/bin/codesign"
    let securityPath = "/usr/bin/security"
    let chmodPath = "/bin/chmod"
    //assets读写
    let acextractPath = Bundle.main.path(forResource: "acextract", ofType: nil)!
    let acegeneralPath = Bundle.main.path(forResource: "acegeneral", ofType: nil)!
    let assetsZipPath = Bundle.main.path(forResource: "Assets.xcassets", ofType: "zip")!
    let ContentJsonPath = Bundle.main.path(forResource: "Contents", ofType: "json")!

    //"/usr/local/bin/acextract"

    //MARK: Drag / Drop
    var fileTypes: [String] = ["ipa","deb","app","xcarchive","mobileprovision"]
    var urlFileTypes: [String] = ["ipa","deb"]
    var fileTypeIsOk = false
    
    func fileDropped(_ filename: String){
        switch(filename.pathExtension.lowercased()){
        case "ipa", "deb", "app", "xcarchive":
            InputFileText.stringValue = filename
            inputFiles.append(filename)
            break
            
        case "mobileprovision":
            ProvisioningProfilesPopup.selectItem(at: 1)
            checkProfileID(ProvisioningProfile(filename: filename))
            break
            
        default: break
            
        }
    }
    
    func urlDropped(_ url: NSURL){
        if let urlString = url.absoluteString {
            InputFileText.stringValue = urlString
            inputFiles.append(urlString)
        }
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(sender) == true {
            self.fileTypeIsOk = true
            return .copy
        } else {
            self.fileTypeIsOk = false
            return NSDragOperation()
        }
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if self.fileTypeIsOk {
            return .copy
        } else {
            return NSDragOperation()
        }
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard()
        if let board = pasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray {
            if let filePath = board[0] as? String {
                
                fileDropped(filePath)
                return true
            }
        }
        if let types = pasteboard.types {
            if #available(OSX 10.13, *) {
                if types.contains(NSPasteboard.PasteboardType.URL) {
                    if let url = NSURL(from: pasteboard) {
                        urlDropped(url)
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
        return false
    }
    
    func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        if let board = drag.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = board[0] as? String {
                return self.fileTypes.contains(path.pathExtension.lowercased())
        }
        if let types = drag.draggingPasteboard().types {
            if #available(OSX 10.13, *) {
                if types.contains(NSPasteboard.PasteboardType.URL) {
                    if let url = NSURL(from: drag.draggingPasteboard()),
                        let suffix = url.pathExtension {
                        return self.urlFileTypes.contains(suffix.lowercased())
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
        return false
    }
    
    //MARK: Functions
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        if #available(OSX 10.13, *) {
            registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL, NSPasteboard.PasteboardType.URL])
        } else {
            // Fallback on earlier versions
        }
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        if #available(OSX 10.13, *) {
            registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL, NSPasteboard.PasteboardType.URL])
        } else {
            // Fallback on earlier versions
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor(red:0.28, green:0.28, blue:0.28, alpha:1.00).cgColor
        self.superSignDataView.wantsLayer = true
        self.superSignDataView.layer!.backgroundColor = NSColor(red:0.28, green:0.28, blue:0.28, alpha:1.00).cgColor

        StartButton.wantsLayer = true
        StartButton.layer!.backgroundColor = NSColor(red:0.00, green:0.56, blue:0.95, alpha:1.00).cgColor
        StartButton.layer!.cornerRadius = 15
        
        CodesigningCertsPopup.wantsLayer = true
        CodesigningCertsPopup.layer!.backgroundColor = NSColor(red:1.00, green:1.00, blue:1.00, alpha:1.00).cgColor
        CodesigningCertsPopup.layer!.cornerRadius = 10
        CodesigningCertsPopup.layer!.borderColor = NSColor(red:0.28, green:0.59, blue:1, alpha:0.35).cgColor
        CodesigningCertsPopup.layer!.borderWidth = 2

        ProvisioningProfilesPopup.wantsLayer = true
        ProvisioningProfilesPopup.layer!.backgroundColor = NSColor(red:1.00, green:1.00, blue:1.00, alpha:1.00).cgColor
        ProvisioningProfilesPopup.layer!.cornerRadius = 10
        ProvisioningProfilesPopup.layer!.borderColor = NSColor(red:0.28, green:0.59, blue:1, alpha:0.35).cgColor
        ProvisioningProfilesPopup.layer!.borderWidth = 2

        InputFileText.wantsLayer = true
        InputFileText.layer!.backgroundColor = NSColor(red:1.00, green:1.00, blue:1.00, alpha:1.00).cgColor
        InputFileText.layer!.cornerRadius = 10
        InputFileText.layer!.borderColor = NSColor(red:0.28, green:0.59, blue:1, alpha:0.35).cgColor
        InputFileText.layer!.borderWidth = 2
        
        issuerIDField.wantsLayer = true
        issuerIDField.layer!.backgroundColor = NSColor(red:1.00, green:1.00, blue:1.00, alpha:1.00).cgColor
        let issuer = UserDefaults.standard.value(forKey: "issuer")
        if issuer != nil {
            issuerIDField.stringValue = issuer as! String
        } else {
            let issue = "ISSUER ID"
            let issueAttribute = NSMutableAttributedString.init(string: issue);
            issueAttribute.addAttributes([NSAttributedString.Key.foregroundColor : NSColor.lightGray], range: NSRange.init(location: 0, length: issue.count))
            issuerIDField.placeholderAttributedString = issueAttribute
        }
        
        privateKeyField.wantsLayer = true
        privateKeyField.layer!.backgroundColor = NSColor(red:1.00, green:1.00, blue:1.00, alpha:1.00).cgColor
        let key = UserDefaults.standard.value(forKey: "privateKey")
        if key != nil {
            privateKeyField.stringValue = key as! String
        } else {
            let privateKey = "Private Key"
            let privateKeyAttribute = NSMutableAttributedString.init(string: privateKey);
            privateKeyAttribute.addAttributes([NSAttributedString.Key.foregroundColor : NSColor.lightGray], range: NSRange.init(location: 0, length: privateKey.count))
            privateKeyField.placeholderAttributedString = privateKeyAttribute
        }
        
        privateKeyIDField.wantsLayer = true
        privateKeyIDField.layer!.backgroundColor = NSColor(red:1.00, green:1.00, blue:1.00, alpha:1.00).cgColor
        let keyId = UserDefaults.standard.value(forKey: "privateKeyId")
        if keyId != nil {
            privateKeyIDField.stringValue = keyId as! String
        } else {
            let privateKeyID = "Private Key ID"
            let privateKeyIDAttribute = NSMutableAttributedString.init(string: privateKeyID);
            privateKeyIDAttribute.addAttributes([NSAttributedString.Key.foregroundColor : NSColor.lightGray], range: NSRange.init(location: 0, length: privateKeyID.count))
            privateKeyIDField.placeholderAttributedString = privateKeyIDAttribute
        }
        
        UDIDsField.wantsLayer = true
        UDIDsField.layer!.backgroundColor = NSColor(red:1.00, green:1.00, blue:1.00, alpha:1.00).cgColor
        let udidKey = "add new device UDIDs, separatedBy ','"
        let udidKeyAttribute = NSMutableAttributedString.init(string: udidKey);
        udidKeyAttribute.addAttributes([NSAttributedString.Key.foregroundColor : NSColor.lightGray], range: NSRange.init(location: 0, length: udidKey.count))
        UDIDsField.placeholderAttributedString = udidKeyAttribute
        
        let signerTipKey = "Sign Online"
        let signerTipAttribute = NSMutableAttributedString.init(string: signerTipKey);
        signerTipAttribute.addAttributes([NSAttributedString.Key.foregroundColor : NSColor.white], range: NSRange.init(location: 0, length: signerTipKey.count))
        signerModeTipField.placeholderAttributedString = signerTipAttribute
        
        if NibLoaded == false {
            NibLoaded = true
            
            // Do any additional setup after loading the view.
            populateCodesigningCerts()
            populateProvisioningProfiles()
            if let defaultCert = defaults.string(forKey: "signingCertificate") {
                if codesigningCerts.contains(defaultCert) {
                    Log.write("Loaded Codesigning Certificate from Defaults: \(defaultCert)")
                    CodesigningCertsPopup.selectItem(withTitle: defaultCert)
                }
            }
            setStatus("Ready")
            if checkXcodeCLI() == false {
                if #available(OSX 10.10, *) {
                    let _ = installXcodeCLI()
                } else {
                    let alert = NSAlert()
                    alert.messageText = "Please install the Xcode command line tools and re-launch this application."
                    alert.runModal()
                }
                
                NSApplication.shared.terminate(self)
            }
        }
    }
    
    @IBAction func EnglishSwitchAction(_ sender: NSButton) {
        
    }
    
    
    func installXcodeCLI() -> AppSignerTaskOutput {
        return Process().execute("/usr/bin/xcode-select", workingDirectory: nil, arguments: ["--install"])
    }
    
    func checkXcodeCLI() -> Bool {
        if #available(OSX 10.10, *) {
            if Process().execute("/usr/bin/xcode-select", workingDirectory: nil, arguments: ["-p"]).status   != 0 {
                return false
            }
        } else {
            if Process().execute("/usr/sbin/pkgutil", workingDirectory: nil, arguments: ["--pkg-info=com.apple.pkg.DeveloperToolsCLI"]).status != 0 {
                // Command line tools not available
                return false
            }
        }
        
        return true
    }
    
    func makeTempFolder()->String?{
        let tempTask = Process().execute(mktempPath, workingDirectory: nil, arguments: ["-d","-t",bundleID!])
        if tempTask.status != 0 {
            return nil
        }
        return tempTask.output.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func setStatus(_ status: String){
        Log.write(status)
        if (!Thread.isMainThread){
            DispatchQueue.main.sync{
                setStatus(status)
            }
        }
        else{
            StatusLabel.stringValue = status
        }
    }
    
    func populateProvisioningProfiles(){
        let zeroWidthSpace = "​"
        self.provisioningProfiles = ProvisioningProfile.getProfiles().sorted {
            ($0.name == $1.name && $0.created.timeIntervalSince1970 > $1.created.timeIntervalSince1970) || $0.name < $1.name
        }
        setStatus("Found \(provisioningProfiles.count) Provisioning Profile\(provisioningProfiles.count>1 || provisioningProfiles.count<1 ? "s":"")")
        ProvisioningProfilesPopup.removeAllItems()
        ProvisioningProfilesPopup.addItems(withTitles: [
            "Re-Sign Only",
            "Choose Custom File",
            "––––––––––––––––––––––"
        ])
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        var newProfiles: [ProvisioningProfile] = []
        var zeroWidthPadding: String = ""
        for profile in provisioningProfiles {
            zeroWidthPadding = "\(zeroWidthPadding)\(zeroWidthSpace)"
            
            if profile.expires.timeIntervalSince1970 > Date().timeIntervalSince1970 {
                
                newProfiles.append(profile)
                ProvisioningProfilesPopup.addItem(withTitle: "\(profile.name)\(zeroWidthPadding) (\(profile.teamID))")
                
                let toolTipItems = [
                    "\(profile.name)",
                    "",
                    "Team ID: \(profile.teamID)",
                    "Team Name: \(profile.teamName)",
                    "Created: \(formatter.string(from: profile.created as Date))",
                    "Expires: \(formatter.string(from: profile.expires as Date))"
                ]
                ProvisioningProfilesPopup.lastItem!.toolTip = toolTipItems.joined(separator: "\n")
                setStatus("Added profile \(profile.appID), expires (\(formatter.string(from: profile.expires as Date)))")
            } else {
                setStatus("Skipped profile \(profile.appID), expired (\(formatter.string(from: profile.expires as Date)))")
            }
        }
        self.provisioningProfiles = newProfiles
        chooseProvisioningProfile(ProvisioningProfilesPopup)
    }
    
    func getCodesigningCerts() -> [String] {
        var output: [String] = []
        let securityResult = Process().execute(securityPath, workingDirectory: nil, arguments: ["find-identity","-v","-p","codesigning"])
        if securityResult.output.characters.count < 1 {
            return output
        }
        
        //以下过滤规则未判断是否失效
//        let rawResult = securityResult.output.components(separatedBy: "\"")
//        var index: Int
//        for index in stride(from: 0, through: rawResult.count - 2, by: 2) {
//            if !(rawResult.count - 1 < index + 1) {
//                output.append(rawResult[index+1])
//            }
//        }
        
        //过滤已失效证书
        let rawResult = securityResult.output.components(separatedBy: "\n")
        for content in rawResult {
            let arr:[String?] = content.components(separatedBy: "\"")
            guard arr.count == 3, var cername = arr[arr.count-2] else {continue}
            if content.hasSuffix("(CSSMERR_TP_CERT_REVOKED)"){
                cername.insert(contentsOf: "【已失效】", at: cername.startIndex)
            }
            output.append(cername)
        }
        
        return output
    }
    
    func showCodesignCertsErrorAlert(){
        let alert = NSAlert()
        alert.messageText = "No codesigning certificates found"
        alert.informativeText = "I can attempt to fix this automatically, would you like me to try?"
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
            if let tempFolder = makeTempFolder() {
                iASShared.fixSigning(tempFolder)
                try? fileManager.removeItem(atPath: tempFolder)
                populateCodesigningCerts()
            }
        }
    }
    
    func populateCodesigningCerts() {
        CodesigningCertsPopup.removeAllItems()
        self.codesigningCerts = getCodesigningCerts()
        
        setStatus("Found \(self.codesigningCerts.count) Codesigning Certificate\(self.codesigningCerts.count>1 || self.codesigningCerts.count<1 ? "s":"")")
        if self.codesigningCerts.count > 0 {
            for cert in self.codesigningCerts {
                CodesigningCertsPopup.addItem(withTitle: cert)
                setStatus("Added signing certificate \"\(cert)\"")
            }
        } else {
            showCodesignCertsErrorAlert()
        }
        
    }
    
    func checkProfileID(_ profile: ProvisioningProfile?){
        if let profile = profile {
            self.profileFilename = profile.filename
            setStatus("Selected provisioning profile \(profile.appID)")
            if profile.expires.timeIntervalSince1970 < Date().timeIntervalSince1970 {
                ProvisioningProfilesPopup.selectItem(at: 0)
                setStatus("Provisioning profile expired")
                chooseProvisioningProfile(ProvisioningProfilesPopup)
            }
            if !profile.isWildcard && !profile.isEnterprise {
                NewApplicationIDTextField.stringValue = profile.appID
                NewApplicationIDTextField.isEnabled = false
            } else {
                if NewApplicationIDTextField.isEnabled == false {
                    NewApplicationIDTextField.stringValue = ""
                    NewApplicationIDTextField.isEnabled = true
                }
            }
        } else {
            ProvisioningProfilesPopup.selectItem(at: 0)
            setStatus("Invalid provisioning profile")
            chooseProvisioningProfile(ProvisioningProfilesPopup)
        }
    }
    
    func controlsEnabled(_ enabled: Bool){
        
        if (!Thread.isMainThread){
            DispatchQueue.main.sync{
                controlsEnabled(enabled)
            }
        }
        else{
            if(enabled){
                InputFileText.isEnabled = true
                BrowseButton.isEnabled = true
                ProvisioningProfilesPopup.isEnabled = true
                CodesigningCertsPopup.isEnabled = true
                NewApplicationIDTextField.isEnabled = ReEnableNewApplicationID
                NewApplicationIDTextField.stringValue = PreviousNewApplicationID
                StartButton.isEnabled = true
                appDisplayName.isEnabled = true
                outputAssetsButton.isEnabled = true
                ReplaceIconChooseButton.isEnabled = true
                openSignerViewButton.isEnabled = true
            } else {
                // Backup previous values
                PreviousNewApplicationID = NewApplicationIDTextField.stringValue
                ReEnableNewApplicationID = NewApplicationIDTextField.isEnabled
                
                InputFileText.isEnabled = false
                BrowseButton.isEnabled = false
                ProvisioningProfilesPopup.isEnabled = false
                CodesigningCertsPopup.isEnabled = false
                NewApplicationIDTextField.isEnabled = false
                StartButton.isEnabled = false
                appDisplayName.isEnabled = false
                outputAssetsButton.isEnabled = false
                ReplaceIconChooseButton.isEnabled = false
                openSignerViewButton.isEnabled = false
            }
        }
    }
    
    func recursiveDirectorySearch(_ path: String, extensions: [String], found: ((_ file: String) -> Void)){
        
        if let files = try? fileManager.contentsOfDirectory(atPath: path) {
            var isDirectory: ObjCBool = true
            
            for file in files {
                let currentFile = path.stringByAppendingPathComponent(file)
                fileManager.fileExists(atPath: currentFile, isDirectory: &isDirectory)
                if isDirectory.boolValue {
                    recursiveDirectorySearch(currentFile, extensions: extensions, found: found)
                }
                if extensions.contains(file.pathExtension) {
                    found(currentFile)
                }
                
            }
        }
    }
    
    func unzip(_ inputFile: String, outputPath: String)->AppSignerTaskOutput {
        return Process().execute(unzipPath, workingDirectory: nil, arguments: ["-q",inputFile,"-d",outputPath])
    }
    func zip(_ inputPath: String, outputFile: String)->AppSignerTaskOutput {
        return Process().execute(zipPath, workingDirectory: inputPath, arguments: ["-qry", outputFile, "."])
    }
    
    func cleanup(_ tempFolder: String){
        do {
            Log.write("Deleting: \(tempFolder)")
            try fileManager.removeItem(atPath: tempFolder)
        } catch let error as NSError {
            setStatus("Unable to delete temp folder")
            Log.write(error.localizedDescription)
        }
        controlsEnabled(true)
    }
    func bytesToSmallestSi(_ size: Double) -> String {
        let prefixes = ["","K","M","G","T","P","E","Z","Y"]
        for i in 1...6 {
            let nextUnit = pow(1024.00, Double(i+1))
            let unitMax = pow(1024.00, Double(i))
            if size < nextUnit {
                return "\(round((size / unitMax)*100)/100)\(prefixes[i])B"
            }
            
        }
        return "\(size)B"
    }
    func getPlistKey(_ plist: String, keyName: String)->String? {
        let currTask = Process().execute(defaultsPath, workingDirectory: nil, arguments: ["read", plist, keyName])
        if currTask.status == 0 {
            return String(currTask.output.characters.dropLast())
        } else {
            return nil
        }
    }
    
    func setPlistKey(_ plist: String, keyName: String, value: String)->AppSignerTaskOutput {
        return Process().execute(defaultsPath, workingDirectory: nil, arguments: ["write", plist, keyName, value])
    }
    
    //MARK: NSURL Delegate
    var downloading = false
    var downloadError: NSError?
    var downloadPath: String!
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        downloadError = downloadTask.error as NSError?
        if downloadError == nil {
            do {
                try fileManager.moveItem(at: location, to: URL(fileURLWithPath: downloadPath))
            } catch let error as NSError {
                setStatus("Unable to move downloaded file")
                Log.write(error.localizedDescription)
            }
        }
        downloading = false
        downloadProgress.doubleValue = 0.0
        downloadProgress.stopAnimation(nil)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        //StatusLabel.stringValue = "Downloading file: \(bytesToSmallestSi(Double(totalBytesWritten))) / \(bytesToSmallestSi(Double(totalBytesExpectedToWrite)))"
        let percentDownloaded = (Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)) * 100
        downloadProgress.doubleValue = percentDownloaded
    }
    
    //MARK: Codesigning
    func codeSign(_ file: String, certificate: String, entitlements: String?,before:((_ file: String, _ certificate: String, _ entitlements: String?)->Void)?, after: ((_ file: String, _ certificate: String, _ entitlements: String?, _ codesignTask: AppSignerTaskOutput)->Void)?)->AppSignerTaskOutput{
        
        let useEntitlements: Bool = ({
            if entitlements == nil {
                return false
            } else {
                if fileManager.fileExists(atPath: entitlements!) {
                    return true
                } else {
                    return false
                }
            }
        })()
        if let beforeFunc = before {
            beforeFunc(file, certificate, entitlements)
        }
        var arguments = ["-vvv","-fs",certificate,"--no-strict"]
        if useEntitlements {
            arguments.append("--entitlements=\(entitlements!)")
        }
        arguments.append(file)
        let codesignTask = Process().execute(codesignPath, workingDirectory: nil, arguments: arguments)
        if let afterFunc = after {
            afterFunc(file, certificate, entitlements, codesignTask)
        }
        return codesignTask
    }
    func testSigning(_ certificate: String, tempFolder: String )->Bool? {
        let codesignTempFile = tempFolder.stringByAppendingPathComponent("test-sign")
        // Copy our binary to the temp folder to use for testing.
        let path = ProcessInfo.processInfo.arguments[0]
        if (try? fileManager.copyItem(atPath: path, toPath: codesignTempFile)) != nil {
            codeSign(codesignTempFile, certificate: certificate, entitlements: nil, before: nil, after: nil)
            
            let verificationTask = Process().execute(codesignPath, workingDirectory: nil, arguments: ["-v",codesignTempFile])
            try? fileManager.removeItem(atPath: codesignTempFile)
            if verificationTask.status == 0 {
                return true
            } else {
                return false
            }
        } else {
            setStatus("Error testing codesign")
        }
        return nil
    }
    
    func startSigning() {
        controlsEnabled(false)
        
        //MARK: Get output filename
        let saveDialog = NSSavePanel()
        saveDialog.allowedFileTypes = ["ipa"]
        var saveName = InputFileText.stringValue.lastPathComponent.stringByDeletingPathExtension
        if inputFiles.count > 1 {
            saveDialog.canCreateDirectories = true
            saveName = "_"
        }
        saveDialog.nameFieldStringValue = saveName
        if saveDialog.runModal().rawValue == NSFileHandlingPanelOKButton {
           
            if inputFiles.count == 0 && (InputFileText.stringValue.hasPrefix("http") || InputFileText.stringValue.hasPrefix("https")){
                inputFiles.append(InputFileText.stringValue)
            }
            if inputFiles.count == 1 {
                
                let inputFile = inputFiles.first
                outputFile = saveDialog.url!.path
                Thread.detachNewThreadSelector(#selector(self.signingThread(_:)), toTarget: self, with: [inputFile,outputFile])
                
            } else {
                
                for in_file_path in inputFiles {
                    
                    let inputFile = in_file_path
                    let outputFile = saveDialog.url!.path.stringByDeletingLastPathComponent.stringByAppendingPathComponent(in_file_path.lastPathComponent)
                    Thread.detachNewThreadSelector(#selector(self.signingThread(_:)), toTarget: self, with: [inputFile,outputFile])
                }
            }
            
        } else {
            outputFile = nil
            controlsEnabled(true)
        }
    }
    
    //创建plist文件
    func buildPlistForIPA(_ ipa_path:String ,bundleId: String) {
        
        let ipaName = ipa_path.lastPathComponent as NSString
        let name = ipaName.components(separatedBy: ".").first! as NSString
        
        //把TestPlist文件加入
        let plistPath = ipa_path.stringByDeletingLastPathComponent.stringByAppendingPathComponent("\(String(describing: name)).plist")

        //开始创建文件
        let res = fileManager.createFile(atPath: plistPath, contents: nil, attributes: nil)
        
        if res {
            
            let bundleInfo = Bundle.main.infoDictionary! as NSDictionary
            let app_version = bundleInfo.object(forKey: "CFBundleShortVersionString")
            let change_version = appVersion.stringValue as NSString;
            
            //写入数据到plist文件
            let metadata = NSMutableDictionary.init(dictionaryLiteral: ("bundle-identifier", bundleId),("bundle-version", change_version.length > 0 ? change_version : app_version as Any),("kind", "software"),("title", name))
            let item = NSDictionary.init(dictionaryLiteral: ("kind", "software-package"),("url", "http://127.0.0.1:10001/\(ipaName)"))
            let assets = [item]

            let dictoryItem = NSMutableDictionary.init(dictionaryLiteral: ("metadata", metadata),("assets", assets))
            let arrayItem = [dictoryItem]
            let rootDic = NSDictionary.init(dictionaryLiteral: ("items", arrayItem))

            //写入
            let wirteRes = rootDic.write(toFile: plistPath, atomically: true)
            if wirteRes {
                print("写入plist文件成功")
            } else {
                print("写入plist文件失败")
            }
       
        } else {
            print("创建plist文件失败")
        }
    }
    
    
    //创建渠道文件
    func buildChannelTxtForIPA(bundlePath : NSString) {
        let channe_name = self.channelName.stringValue as NSString
            
        let txtPath = bundlePath.appendingPathComponent("channel.txt")
        var inputIsDirectory: ObjCBool = false
        let exist = fileManager.fileExists(atPath: txtPath, isDirectory: &inputIsDirectory)
        if !exist {
            fileManager.createFile(atPath: txtPath, contents: nil, attributes: nil)
        }
        // 写入
        do {
            try channe_name.write(toFile: txtPath, atomically: false, encoding: String.Encoding.utf8.rawValue)
            print("string 文件写入成功")
        } catch let error as NSError {
            print("string 文件写入失败 %@",error)
        }
    }
    
    @objc func signingThread(_ paths :[String]){
        
        let input_path = paths[0]
        let output_path = paths[1]
        
        //MARK: Set up variables
        var warnings = 0
        var inputFile : String = ""
        var newApplicationID : String = ""
        var newDisplayName : String = ""
        var newShortVersion : String = ""
        var newVersion : String = ""
        var newIconPath : String = ""

        DispatchQueue.main.sync {
            inputFile = input_path//self.InputFileText.stringValue
            newIconPath = self.ReplaceIconField.stringValue
            if self.openSignerViewButton.state == .off {
                signingCertificate = self.CodesigningCertsPopup.selectedItem?.title
            }
            newApplicationID = self.NewApplicationIDTextField.stringValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            newDisplayName = self.appDisplayName.stringValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            newShortVersion = self.appShortVersion.stringValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            newVersion = self.appVersion.stringValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }

        var provisioningFile = self.profileFilename
        let inputStartsWithHTTP = inputFile.lowercased().substring(to: inputFile.characters.index(inputFile.startIndex, offsetBy: 4)) == "http"
        var eggCount: Int = 0
        var continueSigning: Bool? = nil
        
        //MARK: Sanity checks
        
        // Check signing certificate selection
        if signingCertificate == nil {
            setStatus("No signing certificate selected")
            return
        }
        
        // Check if input file exists
        var inputIsDirectory: ObjCBool = false
        if !inputStartsWithHTTP && !fileManager.fileExists(atPath: inputFile, isDirectory: &inputIsDirectory){
            DispatchQueue.main.async(execute: {
                let alert = NSAlert()
                alert.messageText = "Input file not found"
                alert.addButton(withTitle: "OK")
                alert.informativeText = "The file \(inputFile) could not be found"
                alert.runModal()
                self.controlsEnabled(true)
            })
            return
        }
        
        //MARK: Create working temp folder
        var tempFolder: String! = nil
        if let tmpFolder = makeTempFolder() {
            tempFolder = tmpFolder
        } else {
            setStatus("Error creating temp folder")
            return
        }
        let workingDirectory = tempFolder.stringByAppendingPathComponent("out")
        let eggDirectory = tempFolder.stringByAppendingPathComponent("eggs")
        let payloadDirectory = workingDirectory.stringByAppendingPathComponent("Payload/")
        let entitlementsPlist = tempFolder.stringByAppendingPathComponent("entitlements.plist")
        
        Log.write("Temp folder: \(tempFolder)")
        Log.write("Working directory: \(workingDirectory)")
        Log.write("Payload directory: \(payloadDirectory)")
        
        //MARK: Codesign Test
        
        DispatchQueue.main.async(execute: {
            if let codesignResult = self.testSigning(self.signingCertificate!, tempFolder: tempFolder) {
                if codesignResult == false {
                    let alert = NSAlert()
                    alert.messageText = "Codesigning error"
                    alert.addButton(withTitle: "Yes")
                    alert.addButton(withTitle: "No")
                    alert.informativeText = "You appear to have a error with your codesigning certificate, do you want me to try and fix the problem?"
                    let response = alert.runModal()
                    if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                        iASShared.fixSigning(tempFolder)
                        if self.testSigning(self.signingCertificate!, tempFolder: tempFolder) == false {
                            let errorAlert = NSAlert()
                            errorAlert.messageText = "Unable to Fix"
                            errorAlert.addButton(withTitle: "OK")
                            errorAlert.informativeText = "I was unable to automatically resolve your codesigning issue ☹\n\nIf you have previously trusted your certificate using Keychain, please set the Trust setting back to the system default."
                            errorAlert.runModal()
                            continueSigning = false
                            return
                        }
                    } else {
                        continueSigning = false
                        return
                    }
                }
            }
            continueSigning = true
        })
        
        
        while true {
            if continueSigning != nil {
                if continueSigning! == false {
                    continueSigning = nil
                    cleanup(tempFolder); return
                }
                break
            }
            usleep(100)
        }
        
        //MARK: Create Egg Temp Directory
        do {
            try fileManager.createDirectory(atPath: eggDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            setStatus("Error creating egg temp directory")
            Log.write(error.localizedDescription)
            cleanup(tempFolder); return
        }
        
        //MARK: Download file
        downloading = false
        downloadError = nil
        downloadPath = tempFolder.stringByAppendingPathComponent("download.\(inputFile.pathExtension)")
        
        if inputStartsWithHTTP {
            
            DispatchQueue.main.async(execute: {
                self.downloadProgress.isHidden = false
            })
            let defaultConfigObject = URLSessionConfiguration.default
            let defaultSession = Foundation.URLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: OperationQueue.main)
            if let url = URL(string: inputFile) {
                downloading = true
                let downloadTask = defaultSession.downloadTask(with: url)
                DispatchQueue.main.async(execute: {
                    self.setStatus("Downloading file")
                    self.downloadProgress.startAnimation(nil)
                })
                downloadTask.resume()
                defaultSession.finishTasksAndInvalidate()
            }
            
            while downloading {
                usleep(100000)
            }
            if downloadError != nil {
                setStatus("Error downloading file, \(downloadError!.localizedDescription.lowercased())")
                cleanup(tempFolder); return
            } else {
                inputFile = downloadPath
            }
        }
        
        //MARK: Process input file
        switch(inputFile.pathExtension.lowercased()){
        case "deb":
            //MARK: --Unpack deb
            let debPath = tempFolder.stringByAppendingPathComponent("deb")
            do {
                
                try fileManager.createDirectory(atPath: debPath, withIntermediateDirectories: true, attributes: nil)
                try fileManager.createDirectory(atPath: workingDirectory, withIntermediateDirectories: true, attributes: nil)
                setStatus("Extracting deb file")
                let debTask = Process().execute(arPath, workingDirectory: debPath, arguments: ["-x", inputFile])
                Log.write(debTask.output)
                if debTask.status != 0 {
                    setStatus("Error processing deb file")
                    cleanup(tempFolder); return
                }
                
                var tarUnpacked = false
                for tarFormat in ["tar","tar.gz","tar.bz2","tar.lzma","tar.xz"]{
                    let dataPath = debPath.stringByAppendingPathComponent("data.\(tarFormat)")
                    if fileManager.fileExists(atPath: dataPath){
                        
                        setStatus("Unpacking data.\(tarFormat)")
                        let tarTask = Process().execute(tarPath, workingDirectory: debPath, arguments: ["-xf",dataPath])
                        Log.write(tarTask.output)
                        if tarTask.status == 0 {
                            tarUnpacked = true
                        }
                        break
                    }
                }
                if !tarUnpacked {
                    setStatus("Error unpacking data.tar")
                    cleanup(tempFolder); return
                }
              
              var sourcePath = debPath.stringByAppendingPathComponent("Applications")
              if fileManager.fileExists(atPath: debPath.stringByAppendingPathComponent("var/mobile/Applications")){
                  sourcePath = debPath.stringByAppendingPathComponent("var/mobile/Applications")
              }
              
              try fileManager.moveItem(atPath: sourcePath, toPath: payloadDirectory)
                
            } catch {
                setStatus("Error processing deb file")
                cleanup(tempFolder); return
            }
            break
            
        case "ipa":
            //MARK: --Unzip ipa
            do {
                try fileManager.createDirectory(atPath: workingDirectory, withIntermediateDirectories: true, attributes: nil)
                setStatus("Extracting ipa file")
                
                let unzipTask = self.unzip(inputFile, outputPath: workingDirectory)
                if unzipTask.status != 0 {
                    setStatus("Error extracting ipa file")
                    cleanup(tempFolder); return
                }
            } catch {
                setStatus("Error extracting ipa file")
                cleanup(tempFolder); return
            }
            break
            
        case "app":
            //MARK: --Copy app bundle
            if !inputIsDirectory.boolValue {
                setStatus("Unsupported input file")
                cleanup(tempFolder); return
            }
            do {
                try fileManager.createDirectory(atPath: payloadDirectory, withIntermediateDirectories: true, attributes: nil)
                setStatus("Copying app to payload directory")
                try fileManager.copyItem(atPath: inputFile, toPath: payloadDirectory.stringByAppendingPathComponent(inputFile.lastPathComponent))
            } catch {
                setStatus("Error copying app to payload directory")
                cleanup(tempFolder); return
            }
            break
            
        case "xcarchive":
            //MARK: --Copy app bundle from xcarchive
            if !inputIsDirectory.boolValue {
                setStatus("Unsupported input file")
                cleanup(tempFolder); return
            }
            do {
                try fileManager.createDirectory(atPath: workingDirectory, withIntermediateDirectories: true, attributes: nil)
                setStatus("Copying app to payload directory")
                try fileManager.copyItem(atPath: inputFile.stringByAppendingPathComponent("Products/Applications/"), toPath: payloadDirectory)
            } catch {
                setStatus("Error copying app to payload directory")
                cleanup(tempFolder); return
            }
            break
            
        default:
            setStatus("Unsupported input file")
            cleanup(tempFolder); return
        }
        
        if !fileManager.fileExists(atPath: payloadDirectory){
            setStatus("Payload directory doesn't exist")
            cleanup(tempFolder); return
        }
        
        //这里是用于创建分发的plist文件
        var changedBundle_id: String = ""
        
        // Loop through app bundles in payload directory
        do {
            let files = try fileManager.contentsOfDirectory(atPath: payloadDirectory)
            var isDirectory: ObjCBool = true
            
            for file in files {
                
                fileManager.fileExists(atPath: payloadDirectory.stringByAppendingPathComponent(file), isDirectory: &isDirectory)
                if !isDirectory.boolValue { continue }
                
                //MARK: Bundle variables setup
                let appBundlePath = payloadDirectory.stringByAppendingPathComponent(file)
                let appBundleInfoPlist = appBundlePath.stringByAppendingPathComponent("Info.plist")
                let appBundleProvisioningFilePath = appBundlePath.stringByAppendingPathComponent("embedded.mobileprovision")
                let useAppBundleProfile = (provisioningFile == nil && fileManager.fileExists(atPath: appBundleProvisioningFilePath))
                let ipaAssetsPath = appBundlePath.stringByAppendingPathComponent("Assets.car")

                //MARK: Delete CFBundleResourceSpecification from Info.plist
                Log.write(Process().execute(defaultsPath, workingDirectory: nil, arguments: ["delete",appBundleInfoPlist,"CFBundleResourceSpecification"]).output)
                
                //创建渠道文件
                DispatchQueue.main.sync(execute: {
                    if channelName.stringValue.count > 0 {
                        self.buildChannelTxtForIPA(bundlePath: appBundlePath as NSString)
                    }
                })
                
                //MARK: replace Assets.car
                if newIconPath != "" {
                    if fileManager.fileExists(atPath: newIconPath) {
                        setStatus("General Assets.car")
                        generalAssetsWithFile(newIconPath, bundlePath:appBundlePath)
                    }
                }
                
                //MARK: Copy Provisioning Profile
                if provisioningFile != nil {
                    if fileManager.fileExists(atPath: appBundleProvisioningFilePath) {
                        setStatus("Deleting embedded.mobileprovision")
                        do {
                            try fileManager.removeItem(atPath: appBundleProvisioningFilePath)
                        } catch let error as NSError {
                            setStatus("Error deleting embedded.mobileprovision")
                            Log.write(error.localizedDescription)
                            cleanup(tempFolder); return
                        }
                    }
                    setStatus("Copying provisioning profile to app bundle")
                    do {
                        try fileManager.copyItem(atPath: provisioningFile!, toPath: appBundleProvisioningFilePath)
                    } catch let error as NSError {
                        setStatus("Error copying provisioning profile")
                        Log.write(error.localizedDescription)
                        cleanup(tempFolder); return
                    }
                }
                
                //MARK: Generate entitlements.plist
                if provisioningFile != nil || useAppBundleProfile {
                    setStatus("Parsing entitlements")
                    
                    if let profile = ProvisioningProfile(filename: useAppBundleProfile ? appBundleProvisioningFilePath : provisioningFile!){
                        if let entitlements = profile.getEntitlementsPlist(tempFolder) {
                            Log.write("–––––––––––––––––––––––\n\(entitlements)")
                            Log.write("–––––––––––––––––––––––")
                            do {
                                try entitlements.write(toFile: entitlementsPlist, atomically: false, encoding: String.Encoding.utf8.rawValue)
                                setStatus("Saved entitlements to \(entitlementsPlist)")
                            } catch let error as NSError {
                                setStatus("Error writing entitlements.plist, \(error.localizedDescription)")
                            }
                        } else {
                            setStatus("Unable to read entitlements from provisioning profile")
                            warnings += 1
                        }
                        if !profile.isWildcard && !profile.isEnterprise && (newApplicationID != "" && newApplicationID != profile.appID) {
                            setStatus("Unable to change App ID to \(newApplicationID), provisioning profile won't allow it")
                            cleanup(tempFolder); return
                        }
                    } else {
                        setStatus("Unable to parse provisioning profile, it may be corrupt")
                        warnings += 1
                    }
                    
                }
                
                //MARK: Make sure that the executable is well... executable.
                if let bundleExecutable = getPlistKey(appBundleInfoPlist, keyName: "CFBundleExecutable"){
                    Process().execute(chmodPath, workingDirectory: nil, arguments: ["755", appBundlePath.stringByAppendingPathComponent(bundleExecutable)])
                }
                
                //MARK: Change Application ID
                if newApplicationID != "" {
                    
                    changedBundle_id = newApplicationID
                    if let oldAppID = getPlistKey(appBundleInfoPlist, keyName: "CFBundleIdentifier") {
                        func changeAppexID(_ appexFile: String){
                            let appexPlist = appexFile.stringByAppendingPathComponent("Info.plist")
                            if let appexBundleID = getPlistKey(appexPlist, keyName: "CFBundleIdentifier"){
                                let newAppexID = "\(newApplicationID)\(appexBundleID.substring(from: oldAppID.endIndex))"
                                setStatus("Changing \(appexFile) id to \(newAppexID)")
                                setPlistKey(appexPlist, keyName: "CFBundleIdentifier", value: newAppexID)
                            }
                            if Process().execute(defaultsPath, workingDirectory: nil, arguments: ["read", appexPlist,"WKCompanionAppBundleIdentifier"]).status == 0 {
                                setPlistKey(appexPlist, keyName: "WKCompanionAppBundleIdentifier", value: newApplicationID)
                            }
                            recursiveDirectorySearch(appexFile, extensions: ["app"], found: changeAppexID)
                        }
                        recursiveDirectorySearch(appBundlePath, extensions: ["appex"], found: changeAppexID)
                    }
                    
                    setStatus("Changing App ID to \(newApplicationID)")
                    let IDChangeTask = setPlistKey(appBundleInfoPlist, keyName: "CFBundleIdentifier", value: newApplicationID)
                    if IDChangeTask.status != 0 {
                        setStatus("Error changing App ID")
                        Log.write(IDChangeTask.output)
                        cleanup(tempFolder); return
                    }
                    
                } else {
                    if let oldAppID = getPlistKey(appBundleInfoPlist, keyName: "CFBundleIdentifier") {
                        changedBundle_id = oldAppID
                    }
                }
                
                //MARK: Change Display Name
                if newDisplayName != "" {
                    setStatus("Changing Display Name to \(newDisplayName))")
                    let displayNameChangeTask = Process().execute(defaultsPath, workingDirectory: nil, arguments: ["write",appBundleInfoPlist,"CFBundleDisplayName", newDisplayName])
                    if displayNameChangeTask.status != 0 {
                        setStatus("Error changing display name")
                        Log.write(displayNameChangeTask.output)
                        cleanup(tempFolder); return
                    }
                }
                
                //MARK: Change Version
                if newVersion != "" {
                    setStatus("Changing Version to \(newVersion)")
                    let versionChangeTask = Process().execute(defaultsPath, workingDirectory: nil, arguments: ["write",appBundleInfoPlist,"CFBundleVersion", newVersion])
                    if versionChangeTask.status != 0 {
                        setStatus("Error changing version")
                        Log.write(versionChangeTask.output)
                        cleanup(tempFolder); return
                    }
                }
                
                //MARK: Change Short Version
                if newShortVersion != "" {
                    setStatus("Changing Short Version to \(newShortVersion)")
                    let shortVersionChangeTask = Process().execute(defaultsPath, workingDirectory: nil, arguments: ["write",appBundleInfoPlist,"CFBundleShortVersionString", newShortVersion])
                    if shortVersionChangeTask.status != 0 {
                        setStatus("Error changing short version")
                        Log.write(shortVersionChangeTask.output)
                        cleanup(tempFolder); return
                    }
                }
                
                
                func generateFileSignFunc(_ payloadDirectory:String, entitlementsPath: String, signingCertificate: String)->((_ file:String)->Void){
                    
                    
                    let useEntitlements: Bool = ({
                        if fileManager.fileExists(atPath: entitlementsPath) {
                            return true
                        }
                        return false
                    })()
                    
                    func shortName(_ file: String, payloadDirectory: String)->String{
                        return file.substring(from: payloadDirectory.endIndex)
                    }
                    
                    func beforeFunc(_ file: String, certificate: String, entitlements: String?){
                            setStatus("Codesigning \(shortName(file, payloadDirectory: payloadDirectory))\(useEntitlements ? " with entitlements":"")")
                    }
                    
                    func afterFunc(_ file: String, certificate: String, entitlements: String?, codesignOutput: AppSignerTaskOutput){
                        if codesignOutput.status != 0 {
                            setStatus("Error codesigning \(shortName(file, payloadDirectory: payloadDirectory))")
                            Log.write(codesignOutput.output)
                            warnings += 1
                        }
                    }
                    
                    func output(_ file:String){
                        codeSign(file, certificate: signingCertificate, entitlements: entitlementsPath, before: beforeFunc, after: afterFunc)
                    }
                    
                    return output
                }
                
                //MARK: Codesigning - General
                let signableExtensions = ["dylib","so","0","vis","pvr","framework","appex","app"]
                
                //MARK: Codesigning - Eggs
                let eggSigningFunction = generateFileSignFunc(eggDirectory, entitlementsPath: entitlementsPlist, signingCertificate: signingCertificate!)
                func signEgg(_ eggFile: String){
                    eggCount += 1
                    
                    let currentEggPath = eggDirectory.stringByAppendingPathComponent("egg\(eggCount)")
                    let shortName = eggFile.substring(from: payloadDirectory.endIndex)
                    setStatus("Extracting \(shortName)")
                    if self.unzip(eggFile, outputPath: currentEggPath).status != 0 {
                        Log.write("Error extracting \(shortName)")
                        return
                    }
                    recursiveDirectorySearch(currentEggPath, extensions: ["egg"], found: signEgg)
                    recursiveDirectorySearch(currentEggPath, extensions: signableExtensions, found: eggSigningFunction)
                    setStatus("Compressing \(shortName)")
                    self.zip(currentEggPath, outputFile: eggFile)                    
                }
                
                recursiveDirectorySearch(appBundlePath, extensions: ["egg"], found: signEgg)
                
                //MARK: Codesigning - App
                let signingFunction = generateFileSignFunc(payloadDirectory, entitlementsPath: entitlementsPlist, signingCertificate: signingCertificate!)
                
                
                recursiveDirectorySearch(appBundlePath, extensions: signableExtensions, found: signingFunction)
                signingFunction(appBundlePath)
                
                //MARK: Codesigning - Verification
                let verificationTask = Process().execute(codesignPath, workingDirectory: nil, arguments: ["-v",appBundlePath])
                if verificationTask.status != 0 {
                    DispatchQueue.main.async(execute: {
                        let alert = NSAlert()
                        alert.addButton(withTitle: "OK")
                        alert.messageText = "Error verifying code signature!"
                        alert.informativeText = verificationTask.output
                        alert.alertStyle = .critical
                        alert.runModal()
                        self.setStatus("Error verifying code signature")
                        Log.write(verificationTask.output)
                        self.cleanup(tempFolder); return
                    })
                }
            }
        } catch let error as NSError {
            setStatus("Error listing files in payload directory")
            Log.write(error.localizedDescription)
            cleanup(tempFolder); return
        }
        
        //MARK: Packaging
        //Check if output already exists and delete if so
        if fileManager.fileExists(atPath: output_path) {
            do {
                try fileManager.removeItem(atPath: output_path)
            } catch let error as NSError {
                setStatus("Error deleting output file")
                Log.write(error.localizedDescription)
                cleanup(tempFolder); return
            }
        }
        setStatus("Packaging IPA")
        let zipTask = self.zip(workingDirectory, outputFile: output_path)
        if zipTask.status != 0 {
            setStatus("Error packaging IPA")
        }
        
        //创建OTA分发用的plist文件
        DispatchQueue.main.sync(execute: {
            if generalPlistButton.state == .on {
                buildPlistForIPA(output_path, bundleId: changedBundle_id)
            }
        })
        
        //MARK: Cleanup
        cleanup(tempFolder)
        setStatus("Done, output at \(output_path)")

        inputFiles.removeAll { (content:String) -> Bool in
            return content == input_path
        }
    }

    @IBAction func openSignerViewAction(_ sender: NSButton) {
        
        let hiddenSignerView = sender.state == .off
        self.superSignDataView.isHidden = hiddenSignerView
        
        let signerTipKey = hiddenSignerView ? "Sign Online" : "Sign Online(go https://appstoreconnect.apple.com/access/api to creat private key)"
        let signerTipAttribute = NSMutableAttributedString.init(string: signerTipKey);
        signerTipAttribute.addAttributes([NSAttributedString.Key.foregroundColor : NSColor.white], range: NSRange.init(location: 0, length: signerTipKey.count))
        signerModeTipField.placeholderAttributedString = signerTipAttribute
    }
    
    //MARK: IBActions
    @IBAction func chooseProvisioningProfile(_ sender: NSPopUpButton) {
        
        switch(sender.indexOfSelectedItem){
        case 0:
            self.profileFilename = nil
            if NewApplicationIDTextField.isEnabled == false {
                NewApplicationIDTextField.isEnabled = true
                NewApplicationIDTextField.stringValue = ""
            }
            break
            
        case 1:
            let openDialog = NSOpenPanel()
            openDialog.canChooseFiles = true
            openDialog.canChooseDirectories = false
            openDialog.allowsMultipleSelection = false
            openDialog.allowsOtherFileTypes = false
            openDialog.allowedFileTypes = ["mobileprovision"]
            openDialog.runModal()
            if let filename = openDialog.urls.first {
                checkProfileID(ProvisioningProfile(filename: filename.path))
            } else {
                sender.selectItem(at: 0)
                chooseProvisioningProfile(sender)
            }
            break
            
        case 2:
            sender.selectItem(at: 0)
            chooseProvisioningProfile(sender)
            break
            
        default:
            let profile = provisioningProfiles[sender.indexOfSelectedItem - 3]
            checkProfileID(profile)
            break
        }
        
    }
    
    @IBAction func doBrowse(_ sender: AnyObject) {
        let openDialog = NSOpenPanel()
        openDialog.canChooseFiles = true
        openDialog.canChooseDirectories = false
        openDialog.allowsMultipleSelection = true
        openDialog.allowsOtherFileTypes = false
        openDialog.allowedFileTypes = ["ipa","IPA","deb","DEB","app","APP","xcarchive","XCARCHIVE"]
        openDialog.runModal()
        if let filename = openDialog.urls.first {
            InputFileText.stringValue = "[\(openDialog.urls.count)个包]" + filename.path
            for url in openDialog.urls {
                inputFiles.append(url.path)
            }
            if inputFiles.count > 1 {
                NewApplicationIDTextField.isEnabled = false
                appDisplayName.isEnabled = false
                appVersion.isEnabled = false
                appShortVersion.isEnabled = false
                channelName.isEnabled = false
                generalPlistButton.isEnabled = false
                outputAssetsButton.isEnabled = false
                ReplaceIconChooseButton.isEnabled = false
            }
        }
    }
    
    
    @IBAction func chooseSigningCertificate(_ sender: NSPopUpButton) {
        Log.write("Set Codesigning Certificate Default to: \(sender.stringValue)")
        defaults.setValue(sender.selectedItem?.title, forKey: "signingCertificate")
    }
    

    @IBAction func chooseReplaceIcon(_ sender: Any) {
        let openDialog = NSOpenPanel()
        openDialog.canChooseFiles = true
        openDialog.canChooseDirectories = false
        openDialog.allowsMultipleSelection = false
        openDialog.allowsOtherFileTypes = false
        openDialog.allowedFileTypes = ["png","PNG"]
        openDialog.runModal()
        if let filename = openDialog.urls.first {
            ReplaceIconField.stringValue = filename.path
        }
    }
    
    @IBAction func doSign(_ sender: NSButton) {
        switch(true){
            case (codesigningCerts.count == 0):
                showCodesignCertsErrorAlert()
                break
            
            default:
                NSApplication.shared.windows[0].makeFirstResponder(self)
                
                if self.openSignerViewButton.state == .on {
                    
                    self.prepareForSignWithUDID().done { (res: Bool) in
                        if res == false {
                            self.setStatus("签名失败")
                        } else {
                            self.setStatus("准备完成，开始签名")
                            self.startSigning()
                        }
                    }
                    
                } else {
                    startSigning()
                }
        }
    }
    
    @IBAction func statusLabelClick(_ sender: NSButton) {
        if let outputFile = self.outputFile {
            if fileManager.fileExists(atPath: outputFile) {
                NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: outputFile)])
            }
        }
    }
    
    //导出素材
    @IBAction func extraOutAssets(_ sender: Any) {

        if inputFiles.count != 1 {
            return;
        }

        controlsEnabled(false)

        //MARK: Get output filename
        let saveDialog = NSSavePanel()
        saveDialog.nameFieldStringValue = "Assets"
        if saveDialog.runModal().rawValue == NSFileHandlingPanelOKButton {
            outputFile = saveDialog.url!.path
            Thread.detachNewThreadSelector(#selector(self.startExportAssets), toTarget: self, with: nil)
        } else {
            outputFile = nil
            controlsEnabled(true)
        }
    }
    
    @objc func startExportAssets() {
        
        //MARK: Set up variables
        var inputFile : String = ""
        DispatchQueue.main.sync {
            inputFile = self.InputFileText.stringValue.components(separatedBy: "个包]").last!
        }
        
        let inputStartsWithHTTP = inputFile.lowercased().substring(to: inputFile.characters.index(inputFile.startIndex, offsetBy: 4)) == "http"
        
        // Check if input file exists
        var inputIsDirectory: ObjCBool = false
        if !inputStartsWithHTTP && !fileManager.fileExists(atPath: inputFile, isDirectory: &inputIsDirectory){
            DispatchQueue.main.async(execute: {
                let alert = NSAlert()
                alert.messageText = "Input file not found"
                alert.addButton(withTitle: "OK")
                alert.informativeText = "The file \(inputFile) could not be found"
                alert.runModal()
                self.controlsEnabled(true)
            })
            return
        }
        
        //MARK: Create working temp folder
        var tempFolder: String! = nil
        if let tmpFolder = makeTempFolder() {
            tempFolder = tmpFolder
        } else {
            setStatus("Error creating temp folder")
            return
        }
        let workingDirectory = tempFolder.stringByAppendingPathComponent("out")
        let eggDirectory = tempFolder.stringByAppendingPathComponent("eggs")
        let payloadDirectory = workingDirectory.stringByAppendingPathComponent("Payload/")
        
        //MARK: Create Egg Temp Directory
        do {
            try fileManager.createDirectory(atPath: eggDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            setStatus("Error creating egg temp directory")
            Log.write(error.localizedDescription)
            cleanup(tempFolder); return
        }
        
        //MARK: Download file
        downloading = false
        downloadError = nil
        downloadPath = tempFolder.stringByAppendingPathComponent("download.\(inputFile.pathExtension)")
        
        if inputStartsWithHTTP {
            
            downloadProgress.isHidden = false
            let defaultConfigObject = URLSessionConfiguration.default
            let defaultSession = Foundation.URLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: OperationQueue.main)
            if let url = URL(string: inputFile) {
                downloading = true
                
                let downloadTask = defaultSession.downloadTask(with: url)
                setStatus("Downloading file")
                DispatchQueue.main.sync {
                    downloadProgress.startAnimation(nil)
                }
                downloadTask.resume()
                defaultSession.finishTasksAndInvalidate()
            }
            
            while downloading {
                usleep(100000)
            }
            if downloadError != nil {
                setStatus("Error downloading file, \(downloadError!.localizedDescription.lowercased())")
                cleanup(tempFolder); return
            } else {
                inputFile = downloadPath
            }
        }
        
        //MARK: Process input file
        switch(inputFile.pathExtension.lowercased()){
        case "deb":
            //MARK: --Unpack deb
            let debPath = tempFolder.stringByAppendingPathComponent("deb")
            do {
                
                try fileManager.createDirectory(atPath: debPath, withIntermediateDirectories: true, attributes: nil)
                try fileManager.createDirectory(atPath: workingDirectory, withIntermediateDirectories: true, attributes: nil)
                setStatus("Extracting deb file")
                let debTask = Process().execute(arPath, workingDirectory: debPath, arguments: ["-x", inputFile])
                Log.write(debTask.output)
                if debTask.status != 0 {
                    setStatus("Error processing deb file")
                    cleanup(tempFolder); return
                }
                
                var tarUnpacked = false
                for tarFormat in ["tar","tar.gz","tar.bz2","tar.lzma","tar.xz"]{
                    let dataPath = debPath.stringByAppendingPathComponent("data.\(tarFormat)")
                    if fileManager.fileExists(atPath: dataPath){
                        
                        setStatus("Unpacking data.\(tarFormat)")
                        let tarTask = Process().execute(tarPath, workingDirectory: debPath, arguments: ["-xf",dataPath])
                        Log.write(tarTask.output)
                        if tarTask.status == 0 {
                            tarUnpacked = true
                        }
                        break
                    }
                }
                if !tarUnpacked {
                    setStatus("Error unpacking data.tar")
                    cleanup(tempFolder); return
                }
                
                var sourcePath = debPath.stringByAppendingPathComponent("Applications")
                if fileManager.fileExists(atPath: debPath.stringByAppendingPathComponent("var/mobile/Applications")){
                    sourcePath = debPath.stringByAppendingPathComponent("var/mobile/Applications")
                }
                
                try fileManager.moveItem(atPath: sourcePath, toPath: payloadDirectory)
                
            } catch {
                setStatus("Error processing deb file")
                cleanup(tempFolder); return
            }
            break
            
        case "ipa":
            //MARK: --Unzip ipa
            do {
                try fileManager.createDirectory(atPath: workingDirectory, withIntermediateDirectories: true, attributes: nil)
                setStatus("Extracting ipa file")
                
                let unzipTask = self.unzip(inputFile, outputPath: workingDirectory)
                if unzipTask.status != 0 {
                    setStatus("Error extracting ipa file")
                    cleanup(tempFolder); return
                }
            } catch {
                setStatus("Error extracting ipa file")
                cleanup(tempFolder); return
            }
            break
            
        case "app":
            //MARK: --Copy app bundle
            if !inputIsDirectory.boolValue {
                setStatus("Unsupported input file")
                cleanup(tempFolder); return
            }
            do {
                try fileManager.createDirectory(atPath: payloadDirectory, withIntermediateDirectories: true, attributes: nil)
                setStatus("Copying app to payload directory")
                try fileManager.copyItem(atPath: inputFile, toPath: payloadDirectory.stringByAppendingPathComponent(inputFile.lastPathComponent))
            } catch {
                setStatus("Error copying app to payload directory")
                cleanup(tempFolder); return
            }
            break
            
        case "xcarchive":
            //MARK: --Copy app bundle from xcarchive
            if !inputIsDirectory.boolValue {
                setStatus("Unsupported input file")
                cleanup(tempFolder); return
            }
            do {
                try fileManager.createDirectory(atPath: workingDirectory, withIntermediateDirectories: true, attributes: nil)
                setStatus("Copying app to payload directory")
                try fileManager.copyItem(atPath: inputFile.stringByAppendingPathComponent("Products/Applications/"), toPath: payloadDirectory)
            } catch {
                setStatus("Error copying app to payload directory")
                cleanup(tempFolder); return
            }
            break
            
        default:
            setStatus("Unsupported input file")
            cleanup(tempFolder); return
        }
        
        if !fileManager.fileExists(atPath: payloadDirectory){
            setStatus("Payload directory doesn't exist")
            cleanup(tempFolder); return
        }
        
        // Loop through app bundles in payload directory
        do {
            let files = try fileManager.contentsOfDirectory(atPath: payloadDirectory)
            var isDirectory: ObjCBool = true
            
            for file in files {
                
                fileManager.fileExists(atPath: payloadDirectory.stringByAppendingPathComponent(file), isDirectory: &isDirectory)
                if !isDirectory.boolValue { continue }
                
                //MARK: Bundle variables setup
                let appBundlePath = payloadDirectory.stringByAppendingPathComponent(file)
                let ipaAssetsPath = appBundlePath.stringByAppendingPathComponent("Assets.car")
                
                if fileManager.fileExists(atPath: ipaAssetsPath) {
                    
                    guard let ouputAssetsPath = self.outputFile else {return}
                    let ouputAssetsTask = Process().execute(acextractPath, workingDirectory: nil, arguments: ["-i",ipaAssetsPath,"-o", ouputAssetsPath])
                    if ouputAssetsTask.status != 0 {
                        setStatus("Error ouputAssets")
                        cleanup(tempFolder); return
                    }
                }
            }
        } catch let error as NSError {
            setStatus("Error listing files in payload directory")
            Log.write(error.localizedDescription)
            cleanup(tempFolder); return
        }
        
        
        //MARK: Cleanup
        cleanup(tempFolder)
        setStatus("Done, output at \(outputFile!)")
    }
    
    func generalAssetsWithFile(_ chooseIconPath: String, bundlePath: String) {
        
        guard let newIcon = NSImage.init(contentsOf: URL.init(fileURLWithPath: chooseIconPath)) else {
            setStatus("Error get newIcon from choosed path")
            return
        }
        
        //创建临时文件夹
        //MARK: Create working temp folder
        let tempTask = Process().execute(mktempPath, workingDirectory: nil, arguments: ["-d","-t","tempAssets"])
        if tempTask.status != 0 {
            setStatus("Error creating assets folder")
            return
        }
        let tempAssets = tempTask.output.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        //将默认assets文件解压到临时文件夹
        let unzipTask = self.unzip(assetsZipPath, outputPath: tempAssets)
        if unzipTask.status != 0 {
            setStatus("Error unzip Assets file")
            cleanup(tempAssets); return
        }
        
        //将命令文件复制到临时文件夹，并返回path
        let acegeneralFile = tempAssets.stringByAppendingPathComponent("acegenetal")
        if (try? fileManager.copyItem(atPath: acegeneralPath, toPath: acegeneralFile)) == nil {
            setStatus("Error general Assets tempFile")
            cleanup(tempAssets); return
        }
        if fileManager.fileExists(atPath: acegeneralFile) == false {
            setStatus("Error general cmd")
            cleanup(tempAssets); return
        };
        
        //创建临时存储新icons的文件夹
        //MARK: Create working temp folder
        let tempIconsTask = Process().execute(mktempPath, workingDirectory: nil, arguments: ["-d","-t","tmpIcons"])
        if tempIconsTask.status != 0 {
            setStatus("Error creating assets folder")
            cleanup(tempAssets); return
        }
        let iconsTmpPath = tempIconsTask.output.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        //遍历默认tempAssets/Assets.xcassets/AppIcon.appiconset文件夹下所有png格式的文件，并生成名称大小一样的新icon
        let iconsPath = tempAssets.stringByAppendingPathComponent("Assets.xcassets/AppIcon.appiconset")
        guard let contents = fileManager.enumerator(atPath: iconsPath) else {
            setStatus("Error read Assets.xcassets")
            cleanup(iconsTmpPath);
            cleanup(tempAssets); return
        }
        while let iconPath = contents.nextObject() {
            
            let iconName = iconPath as! String
            setStatus("replace \(iconName)")

            let path = iconsPath.stringByAppendingPathComponent(iconName)

            guard let imageReps = NSBitmapImageRep.imageReps(withContentsOf: URL.init(fileURLWithPath: path)) else {continue}
            var width = 0
            var height = 0
            for imageRep in imageReps {
                if imageRep.pixelsWide > width{
                    width = imageRep.pixelsWide
                }
                if imageRep.pixelsHigh > height{
                    height = imageRep.pixelsHigh
                }
            }
            let iconSize = CGSize.init(width: width, height: height)
            print("name：\(iconName)  size：\(iconSize)")
            
            //根据解析结果和选择的icon生成指定大小和名称的新icon，替换 tempAssets/Assets.xcassets/AppIcon.appiconset/iconName
            let newSizeIcon = newIcon.resize(iconSize)
            let iconsTmpSavePath = iconsTmpPath.stringByAppendingPathComponent(iconName)

            if saveImg(newSizeIcon, toPath: iconsTmpSavePath, size: iconSize) == false {
                setStatus("Error general new icon")
                cleanup(tempAssets);
                break
            }
        }
        
        //获取新icon临时目录下所有文件，替换原assets包下的icon
        guard let newcontents = fileManager.enumerator(atPath: iconsTmpPath) else {
            setStatus("Error replace Assets")
            cleanup(iconsTmpPath);
            cleanup(tempAssets); return
        }
        while let newiconPath = newcontents.nextObject() {
            
            let newiconName = newiconPath as! String
            let newiconpath = iconsTmpPath.stringByAppendingPathComponent(newiconName)
            let oldSizeIconPath = tempAssets.stringByAppendingPathComponent("Assets.xcassets/AppIcon.appiconset").stringByAppendingPathComponent(newiconName)
            if (try? fileManager.replaceItemAt(NSURL.fileURL(withPath: oldSizeIconPath), withItemAt: NSURL.fileURL(withPath: newiconpath))) == nil {
                setStatus("Error replace Assets")
                cleanup(iconsTmpPath);
                cleanup(tempAssets); return
            }
        }
        //清除临时icon文件夹
        cleanup(iconsTmpPath);
        
        //解压原包内Assets.car文件
        //遍历原Assets文件下所有文件，根据文件名进行分组
        //创建临时文件夹
        setStatus("upzip origin Assets")
        //MARK: Create working temp folder
        let originTask = Process().execute(mktempPath, workingDirectory: nil, arguments: ["-d","-t","originAssets"])
        if tempTask.status != 0 {
            setStatus("Error replace origin Assets")
        }
        let originAssetsUnzipPath = originTask.output.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        //将默认assets文件解压到临时文件夹
        let originAssetsFile = bundlePath.stringByAppendingPathComponent("Assets.car")
        let acetractAssetsTask = Process().execute(acextractPath, workingDirectory: nil, arguments: ["-i",originAssetsFile,"-o",originAssetsUnzipPath])
        if acetractAssetsTask.status != 0 {
            setStatus("Error run general cmd")
            cleanup(originAssetsUnzipPath);
        }
        
        setStatus("analazy origin Assets file")
        //根据文件名创建对应的文件夹和json文件
        let originAssetsContents = fileManager.enumerator(atPath: originAssetsUnzipPath)
        while let originIconPath = originAssetsContents?.nextObject() {
            
            //icon_btn20x20@2x
            let iconName = originIconPath as! String
            let path = originAssetsUnzipPath.stringByAppendingPathComponent(iconName)
            //删除appicon文件
            if iconName.hasPrefix("AppIcon") {
                try? fileManager.removeItem(at: URL(fileURLWithPath: path))
                continue
            }
            guard let image = NSImage.init(contentsOf: URL(fileURLWithPath: path)) else {continue}
           
            let iconSize = image.size
            let sizeString = "\(Int(iconSize.width))x\(Int(iconSize.height))"
            guard let saveName = iconName.components(separatedBy: sizeString).first else {continue}
            guard let scaleString = iconName.components(separatedBy: sizeString).last else {continue}
            
            let folderName = originAssetsUnzipPath.stringByAppendingPathComponent(saveName)+".imageset"
            
            //创建文件夹
            if fileManager.fileExists(atPath: folderName) == false {
                   
                if (try? fileManager.createDirectory(at: URL(fileURLWithPath: folderName), withIntermediateDirectories: true, attributes: nil)) == nil {
                    setStatus("Error replace Assets")
                }
                
                //创建Contents.json
                if let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: ContentJsonPath)) {
                    
                    let contentJson = try? JSONSerialization.jsonObject(with: jsonData, options:.allowFragments)
                    if var releases = contentJson as? [String: AnyObject],
                        var release = releases["images"] as? [[String: String]] {
                        
                        for var item in release{
                            
                            let index = release.index(of: item)
                            let scale: String = item["scale"]!
                            if scale == "2x" {
                                item["filename"] = saveName+"@2x.png"
                            } else if scale == "3x" {
                                item["filename"] = saveName+"@3x.png"
                            }
                            
                            release[index!] = item
                        }
                        
                        releases["images"] = release as AnyObject
                        
                        let ContentJsonSaveName = originAssetsUnzipPath.stringByAppendingPathComponent(saveName)+".imageset"+"/Contents.json"
                        if fileManager.fileExists(atPath: ContentJsonSaveName) == false {
                            
                            let os = OutputStream(toFileAtPath: ContentJsonSaveName,
                                                  append: false)
                            os?.open()
                            JSONSerialization.writeJSONObject(releases,
                                                              to: os!,
                                                              options: JSONSerialization.WritingOptions.prettyPrinted,
                                                              error: NSErrorPointer.none)
                            os?.close()
                        }
                    }
                }
            };
               
            //移动到文件夹下
            if (try? fileManager.moveItem(at: URL(fileURLWithPath: path), to: URL(fileURLWithPath: folderName.stringByAppendingPathComponent(saveName+scaleString)))) == nil {
                setStatus("Error replace Assets")
            }
        }
        
        setStatus("package new Assets")
        //将创建的所有文件夹移动到新的默认的Assets.xcassets目录下
        let assetsFirstFolder = tempAssets.stringByAppendingPathComponent("Assets.xcassets")
        let assetsMoveToPath = assetsFirstFolder.stringByAppendingPathComponent(originAssetsUnzipPath.lastPathComponent)
        if (try? fileManager.moveItem(atPath: originAssetsUnzipPath, toPath: assetsMoveToPath)) == nil {
            setStatus("Error replace Assets")
        }
        
        //执行命令生成build文件夹
        let generalAssetsTask = Process().execute(acegeneralFile, workingDirectory: nil, arguments: nil)
        if generalAssetsTask.status != 0 {
            setStatus("Error run general cmd")
            cleanup(tempAssets);
            cleanup(tempAssets); return
        }
        
        //将build/assets.car文件移动到app目录下
        let carPath = tempAssets.stringByAppendingPathComponent("build/Assets.car")
        if fileManager.fileExists(atPath: carPath) == false {
            setStatus("Error general Assets")
            cleanup(tempAssets);
            cleanup(tempAssets); return
        };
        
        //替换原文件
        let assetsPath = bundlePath.stringByAppendingPathComponent("Assets.car")
        if (try? fileManager.replaceItemAt(NSURL.fileURL(withPath: assetsPath), withItemAt: NSURL.fileURL(withPath: carPath))) == nil {
            setStatus("Error replace Assets")
            cleanup(tempAssets);
            cleanup(tempAssets); return
        }

        setStatus("Replace Assets Done")
    }
    
    func saveImg(_ image: NSImage, toPath:String?, size:CGSize) -> Bool {
        
        image.lockFocus()
        let bits = NSBitmapImageRep.init(focusedViewRect: NSRect.init(x: 0, y: 0, width: size.width, height: size.height))
        image.unlockFocus()
        let imageProps: NSDictionary = NSDictionary.init(dictionary: [NSBitmapImageRep.PropertyKey.compressionFactor:false])
        let imageData = bits!.representation(using: NSBitmapImageRep.FileType.png, properties: imageProps as! [NSBitmapImageRep.PropertyKey : Any])
        if (try? imageData!.write(to: URL.init(fileURLWithPath: toPath!), options: Data.WritingOptions.atomic)) != nil {
            return true
        }
        
        return false
    }
}


extension NSImage {
    
    func resize(_ to: CGSize, isPixels: Bool = false) -> NSImage {
        
        var toSize = to
        let screenScale: CGFloat = NSScreen.main?.backingScaleFactor ?? 1.0

        if isPixels {
            
            toSize.width = to.width / screenScale
            toSize.height = to.height / screenScale
        }
    
        let toRect = NSRect(x: 0, y: 0, width: toSize.width, height: toSize.height)
        let fromRect =  NSRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let newImage = NSImage(size: toRect.size)
        newImage.lockFocus()
        draw(in: toRect, from: fromRect, operation: NSCompositingOperation.copy, fraction: 1.0)
        newImage.unlockFocus()
    
        return newImage
    }
}


extension Float {
 
    /// 小数点后如果只是0，显示整数，如果不是，显示原来的值
    var cleanZero : String {return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)}
}


extension MainView {
    
    private func chooseCsr() -> Promise<String> {
        
        let p = Promise<String> { resolver in
        
            let openDialog = NSOpenPanel()
            openDialog.canChooseFiles = true
            openDialog.canChooseDirectories = false
            openDialog.allowsMultipleSelection = false
            openDialog.allowsOtherFileTypes = false
            openDialog.allowedFileTypes = ["certSigningRequest"]
            openDialog.message = "请选择.certSigningRequest文件(仅首次使用需要，在钥匙串-证书助理申请）"
            openDialog.title = "请选择"
            openDialog.runModal()
            if let filename = openDialog.urls.first {
                resolver.fulfill(filename.path)
            } else {
                let error = NSError.init(domain: "选择CSR文件失败", code: 0, userInfo: nil)
                resolver.reject(error)
            }
    
        }
        
        return p
    }
    
    private func prepareForSignWithUDID() -> Promise<Bool> {
        
        let p = Promise<Bool> { resolver in
            
            self.setStatus("开始注册")

            let issuer = self.issuerIDField.stringValue
            let privateKey = self.privateKeyField.stringValue
            let privateKeyId = self.privateKeyIDField.stringValue
            guard issuer.count > 0 && privateKey.count > 0 && privateKeyId.count > 0 else {
                setStatus("请前往 https://appstoreconnect.apple.com/access/api 生成密钥并填写在指定栏目")
                resolver.fulfill(false)
                return
            }
            
            configuration = APIConfiguration(issuerID: issuer, privateKeyID: privateKeyId, privateKey: privateKey)
            provider = APIProvider(configuration: configuration!)

            UserDefaults.standard.set(issuer, forKey: "issuer")
            UserDefaults.standard.set(privateKey, forKey: "privateKey")
            UserDefaults.standard.set(privateKeyId, forKey: "privateKeyId")
            
            var registerDevices: [Device] = []
            var certificate: Certificate?
            let profile_name = "ecsigner"
            let cer_display_name = "Created via API"
            var registerMoreDevices: Bool = false
            
            //创建临时文件夹保存下载的签名证书和描述文件
            //MARK: Create working temp folder
            let tempTask = Process().execute(mktempPath, workingDirectory: nil, arguments: ["-d","-t","ecsigner_files"])
            if tempTask.status != 0 {
                let def_error = NSError.init(domain: "下载证书失败", code: 0, userInfo: nil)
                resolver.reject(def_error)
                return
            }
            let tempPath = tempTask.output.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            self.listAllCertificatesWithDisplayName(cer_display_name).then({ (certificates: [Certificate]) -> Promise<Certificate> in
                
                self.setStatus("获取证书列表")

                for certificate in certificates {
                    if certificate.attributes?.displayName == cer_display_name {
                        let p = Promise<Certificate> { resolver in
                            resolver.fulfill(certificate)
                        }
                        return p
                    }
                }
                
                return self.chooseCsr().then({ (CSRFilePath: String) -> Promise<Certificate> in
                    
                    self.setStatus("创建证书")
                    return self.creatCertificate(CSRPath: CSRFilePath)
                })
            
            }).then({ (cer: Certificate) -> Promise<Certificate> in
                
                self.setStatus("读取证书")
                return self.readCertificateInfomation(id: cer.id)
            
            }).then({ (cer: Certificate) -> Promise<String> in
                
                self.setStatus("下载证书")
                certificate = cer
                self.signingCertificate = "iPhone Developer: \(certificate!.attributes!.displayName!) (\(self.privateKeyIDField.stringValue))"
                let cerContent = cer.attributes?.certificateContent
                return self.saveFileWithContent(cerContent, filePath: tempPath.stringByAppendingPathComponent("ecsigner.cer"))
            
            }).then({ (cer_path: String) -> Promise<[Device]> in
                
                self.setStatus("获取注册设备")
                return self.listRegisterdDevices()
            
            }).then { (devices: [Device]) -> Promise<[Device]> in
                
                self.setStatus("注册新设备")
                registerDevices.append(contentsOf: devices)

                var udids = self.UDIDsField.stringValue.components(separatedBy: ",")
                if udids.count == 1 && udids.first == "" {
                    udids.removeAll()
                }
                for device in devices.sorted(by: { $0.attributes!.addedDate! > $1.attributes!.addedDate! }) {
                    if udids.contains((device.attributes?.udid)!) {
                        
                        udids.removeAll(where: { (udid:String) -> Bool in
                            return udid == device.attributes?.udid
                        })
                    }
                }
                
                return self.registerdNewDevices(udids:udids, platform: .ios)
                
            }.then({ (devices: [Device]) -> Promise<[Profile]> in
                
                registerMoreDevices = devices.count > 0
                self.setStatus("读取签名文件列表")
                registerDevices.append(contentsOf: devices)
                return self.listAllProfilesWithName(profile_name)
                    
            }).then({ (profiles: [Profile]) -> Promise<Profile> in
                
                self.setStatus("更新签名文件")
                let certificates = [certificate!.id]
                var device_ids: [String] = []
                for register_device in registerDevices {
                    device_ids.append(register_device.id)
                }
                
                let bundleId = "*"
                if profiles.count > 0 {
                    
                    //有新设备注册
                    if  registerMoreDevices == true {
                        
                        return self.deleteProvisionFile(id: profiles.first!.id).then({ () -> Promise<Profile> in
                            return self.creatProvisionFile(name: profile_name, bundleId: bundleId, certificates: certificates, devices: device_ids)
                        })
    
                    } else {
                        let p = Promise<Profile> { resolver in
                            resolver.fulfill(profiles.first!)
                        }
                        return p
                    }
                }
                
                //如果不存在通配符证书则判断是否存在通配符BundleId
                return self.listBundles().then({ (bundleIds: [BundleId]) -> Promise<BundleId> in
                    
                    //创建通配符证书ID
                    if bundleIds.count == 0 {
                        //创建通配符证书
                        return self.creatBundleId(id: bundleId, name: profile_name)
                    
                    } else {
                        let p = Promise<BundleId> { resolver in
                            resolver.fulfill(bundleIds.first!)
                        }
                        return p
                    }
                    
                }).then({ (bundleId: BundleId) -> Promise<Profile> in
                    
                    let certificates = [certificate!.id]
                    var device_ids: [String] = []
                    for register_device in registerDevices {
                        device_ids.append(register_device.id)
                    }
                    return self.creatProvisionFile(name: profile_name, bundleId: bundleId.id, certificates: certificates, devices: device_ids)
                })
                
            }).then({ (profile: Profile) -> Promise<Profile> in
                
                self.setStatus("下载签名文件")
                return self.readProfileInfomation(id: profile.id)
                
            }).then({ (profile: Profile) -> Promise<String> in
                
                let cerContent = profile.attributes?.profileContent
                return self.saveFileWithContent(cerContent, filePath: tempPath.stringByAppendingPathComponent("ecsigner.mobileprovision"))
                    
            }).done({ (profile_path: String) in
                
                self.profileFilename = profile_path
                self.setStatus("更新签名文件成功")
                resolver.fulfill(true)
                    
            }).catch { (error: Error) in
                    
                self.setStatus("下载签名证书失败，签名失败")
                resolver.fulfill(false)
            }
        }
        
        
        return p
    }
    
    private func listRegisterdDevices() -> Promise<[Device]> {
        
        let p = Promise<[Device]> { resolver in
            
            let endpoint = APIEndpoint.listDevices(
                fields: [.devices([.addedDate, .udid, .deviceClass, .model, .name, .platform, .status])],
                limit: 100,
                sort: [.udidAscending])
            provider!.request(endpoint) {
                switch $0 {
                case .success(let devicesResponse):
                    let devices = devicesResponse.data as [Device]
                    resolver.fulfill(devices)
                    for device in devices.sorted(by: { $0.attributes!.addedDate! > $1.attributes!.addedDate! }) {
                        print("device - \(device.attributes!.name!): \(device.attributes!.udid!)")
                    }
                case .failure(let error):
                    resolver.reject(error)
                    print("Something went wrong list the registerd devices: \(error)")
                }
            }
        }
        
        return p
    }
    
    private func registerdNewDevices(udids: [String], platform: Platform) -> Promise<[Device]> {
        
        let p = Promise<[Device]> { resolver in
        
            if udids.count == 0 {
                resolver.fulfill([])
                return
            }
            
            // 创建调度组
            let workingGroup = DispatchGroup()
            let workingQueue = DispatchQueue(label: "request_register_device")
            var register_devices: [Device] = []
            
            for udid in udids {
                
                workingGroup.enter()
                workingQueue.async {
                    
                    let endpoint = APIEndpoint.registerNewDevice(name: udid, udid: udid, platform: platform)
                    self.provider!.request(endpoint) {
                        switch $0 {
                        case .success(let deviceResponse):
                            let device = deviceResponse.data
                            register_devices.append(device)
                        case .failure(_):
                            print("udidRegisterError:\(udid)\n")
                        }
                    }
                    // 出组
                    workingGroup.leave()
                }
            }
            
            // 调度组里的任务都执行完毕
            workingGroup.notify(queue: workingQueue) {
                resolver.fulfill(register_devices)
            }
        }
        
        return p
    }
    
    private func listBundles() -> Promise<[BundleId]> {
        
        let p = Promise<[BundleId]> { resolver in
            
            let endpoint = APIEndpoint.bundleIds(fields: [.bundleIds([.bundleIdCapabilities, .identifier, .name, .platform, .profiles, .seedId])], filter: [.identifier(["*"])])
            provider!.request(endpoint) {
                switch $0 {
                case .success(let bundleIdResponse):
                    let bundleIds = bundleIdResponse.data
                    resolver.fulfill(bundleIds)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    private func creatBundleId(id: String, name: String) -> Promise<BundleId> {
    
        let p = Promise<BundleId> { resolver in
            
            let endpoint = APIEndpoint.register(bundle_id: id, name: name, platform: .ios)
            provider!.request(endpoint) {
                switch $0 {
                case .success(let bundleIdResponse):
                    let bundleId: BundleId = bundleIdResponse.data
                    resolver.fulfill(bundleId)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    
    private func listAllCertificatesWithDisplayName(_ displatName: String) -> Promise<[Certificate]> {
        
        let p = Promise<[Certificate]> { resolver in
            
            let endpoint = APIEndpoint.listAndDownloadCertificates(filter: [.displayName([displatName])])
            provider!.request(endpoint) {
                switch $0 {
                case .success(let certificatesResponse):
                    let certificates = certificatesResponse.data
                    resolver.fulfill(certificates)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    private func creatCertificate(CSRPath: String) -> Promise<Certificate> {
        
        let p = Promise<Certificate> { resolver in
        
            var CSR_Data: Data?
            do {
                CSR_Data = try Data.init(contentsOf: URL.init(fileURLWithPath: CSRPath))
            } catch let error as NSError {
                resolver.reject(error)
            }
            guard let CSRData = CSR_Data else {
                let error = NSError.init(domain: "读取CSR文件失败", code: 0, userInfo: nil)
                resolver.reject(error)
                return
            }
            
            guard let csrContent = String.init(data: CSRData, encoding: .utf8) else {
                let error = NSError.init(domain: "创建certificate失败", code: 0, userInfo: nil)
                resolver.reject(error)
                return
            }
            
            //name: "Created via API"
            let endpoint = APIEndpoint.creatCertificate(certificateType: .ios_development, csrContent: csrContent)
            provider!.request(endpoint) {
                switch $0 {
                case .success(let certificateResponse):
                    let  certificate = certificateResponse.data
                    resolver.fulfill( certificate)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    private func readCertificateInfomation(id: String) -> Promise<Certificate> {
        
        let p = Promise<Certificate> { resolver in
            
            let endpoint = APIEndpoint.readAndDownloadCertificateInfomation(id: id, fields: [.certificates([.certificateContent, .certificateType, .csrContent, .displayName, .expirationDate, .name, .platform, .serialNumber])])
            provider!.request(endpoint) {
                switch $0 {
                case .success(let certificateResponse):
                    let  cer = certificateResponse.data
                    resolver.fulfill(cer)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    //echo content | base64 -D > fileName
    private func saveFileWithContent(_ content: String?, filePath:String) -> Promise<String> {
    
        let p = Promise<String> { resolver in
            
            guard content != nil else {

                let def_error = NSError.init(domain: "下载证书失败", code: 0, userInfo: nil)
                resolver.reject(def_error)
                return
            }
            guard let data = NSData.init(base64Encoded: content!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) else {
                let def_error = NSError.init(domain: "下载证书失败", code: 0, userInfo: nil)
                resolver.reject(def_error)
                return
            }
            data.write(to: URL.init(fileURLWithPath: filePath), atomically: false)

            //导入证书 security add-certificates
            if filePath.hasSuffix(".cer") {
              
                let _ = Process().execute("/usr/bin/security", workingDirectory: nil, arguments: ["add-certificates",filePath])
                self.setStatus("证书下载成功")
                print("证书下载成功\(filePath)")
                resolver.fulfill(filePath)
                
            } else {
                
                let fileManager = FileManager()
                if let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first {
                    let provisioningProfilesPath = libraryDirectory.path.stringByAppendingPathComponent("MobileDevice/Provisioning Profiles") as NSString
                    let destinationPath = provisioningProfilesPath.appendingPathComponent(filePath.lastPathComponent)
                    do {
                        try fileManager.copyItem(atPath: filePath, toPath: destinationPath)
                    } catch {
                        
                    }
                }
                
                print("签名文件下载成功\(filePath)")
                self.setStatus("签名文件下载成功")
                resolver.fulfill(filePath)
            }
        }
        
        return p
    }
    
    private func listAllProfilesWithName(_ name: String) -> Promise<[Profile]> {
        
        let p = Promise<[Profile]> { resolver in
            
            let endpoint = APIEndpoint.listAndDownloadProfiles(fields: [.profiles([.bundleId, .certificates, .createdDate, .devices, .expirationDate, .name, .platform, .profileContent, .profileState, .profileType, .uuid]), .certificates([.certificateContent, .certificateType, .csrContent, .displayName, .expirationDate, .name, .platform, .serialNumber])], filter: [.name([name])])
            provider!.request(endpoint) {
                switch $0 {
                case .success(let profilesResponse):
                    let profiles = profilesResponse.data
                    resolver.fulfill(profiles)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    private func readProfileInfomation(id: String) -> Promise<Profile> {
        
        let p = Promise<Profile> { resolver in
            
            let endpoint = APIEndpoint.readAndDownloadProfilefomation(id: id, fields: [.profiles([.bundleId, .certificates, .createdDate, .devices, .expirationDate, .name, .platform, .profileContent, .profileState, .profileType, .uuid])])
            provider!.request(endpoint) {
                switch $0 {
                case .success(let profilesResponse):
                    let profiles = profilesResponse.data
                    resolver.fulfill(profiles)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    private func creatProvisionFile(name : String,
                                    bundleId : String,
                                    certificates : [String],
                                    devices : [String]) -> Promise<Profile> {
        
        let p = Promise<Profile> { resolver in
            
            let endpoint = APIEndpoint.creatProfile(name: name, profileType: ProfileType.ios_development.rawValue, bundle_id: bundleId, certificates: certificates, devices: devices)
            provider!.request(endpoint) {
                switch $0 {
                case .success(let profileResponse):
                    let profile = profileResponse.data
                    resolver.fulfill(profile)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
    
    private func deleteProvisionFile(id : String) -> Promise<Void> {
        
        let p = Promise<Void> { resolver in
            
            let endpoint = APIEndpoint.deleteProfile(id: id)
            provider!.request(endpoint) {
                switch $0 {
                case .success(let profileResponse):
                    resolver.fulfill(profileResponse)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
        
        return p
    }
}
