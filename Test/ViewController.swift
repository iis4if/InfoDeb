//
//  ViewController.swift
//  Test
//
//  Created by سيف الخليدي on 30/03/1441 AH.
//  Copyright © 1441 iiS4iF. All rights reserved.
// Twitter @iiS4iF 

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var Name: NSTextField!
    @IBOutlet weak var PackageName: NSTextField!
    @IBOutlet weak var Package: NSTextField!
    @IBOutlet weak var Section: NSTextField!
    @IBOutlet weak var Version: NSTextField!
    @IBOutlet weak var PackageAuthor: NSTextField!
    @IBOutlet weak var Description: NSTextField!
    @IBOutlet weak var PackageSize: NSTextField!
    @IBOutlet weak var InstalledSize: NSTextField!
    @IBOutlet weak var PackageMaintainer: NSTextField!
    @IBOutlet weak var PackageArchitecture: NSTextField!
    @IBOutlet weak var PackageIcon: NSTextField!
    @IBOutlet weak var PackageFileName: NSTextField!
    @IBOutlet weak var PackageSileoDepiction: NSTextField!
    @IBOutlet weak var PackageDepiction: NSTextField!
    @IBOutlet weak var md5: NSTextField!
    @IBOutlet weak var sha1: NSTextField!
    @IBOutlet weak var sha256: NSTextField!
    @IBOutlet weak var Depends: NSTextField!
    @IBOutlet weak var Conflicts: NSTextField!
    @IBOutlet weak var Replaces: NSTextField!
    @IBOutlet weak var Provides: NSTextField!
    
    var Encrypt = ""
    
    override func viewDidLoad() {
        
        _ = shell("rm -rf ~/Encrypt? && rm -rf ~/Encrypt")
        Encrypt = shell("echo ~/Encrypt")
        
    }
    
    @IBAction func myButton(_ sender: Any) {
           
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["deb"]
        panel.message = "Open .deb file"
        
        let response = panel.runModal()
        
        if response == NSApplication.ModalResponse.OK {
            
            guard let selectedURL = panel.url else { return }
            
            let FolderPath = selectedURL.absoluteString
            let FolderDirPath = FolderPath.replacingOccurrences(of: "file://", with: "")

            Name.stringValue   = "\(URL(fileURLWithPath: FolderDirPath).lastPathComponent)"
            md5.stringValue    = shell("echo -n \(FolderDirPath) | openssl dgst -md5")
            sha1.stringValue   = shell("echo -n \(FolderDirPath) | openssl dgst -sha1")
            sha256.stringValue = shell("echo -n \(FolderDirPath) | openssl dgst -sha256")
            
            _ = dpkg_deb(FolderDirPath)
            let output = shell("cat \"\(Encrypt)/control\"")
            _ = shell("rm -rf ~/Encrypt? && rm -rf ~/Encrypt")

            PackageName.stringValue = "\(String(describing: output.substring(from: "Name: ", to: "\n", options: .caseInsensitive) ?? ""))"
            Package.stringValue = "\(String(describing: output.substring(from: "Package: ", to: "\n", options: .caseInsensitive) ?? ""))"
            Section.stringValue = "\(String(describing: output.substring(from: "Section: ", to: "\n", options: .caseInsensitive) ?? ""))"
            Version.stringValue = "\(String(describing: output.substring(from: "Version: ", to: "\n", options: .caseInsensitive) ?? ""))"
            Description.stringValue = "\(String(describing: output.substring(from: "Description: ", to: "\n", options: .caseInsensitive) ?? ""))"
            PackageSize.stringValue =  "\(GetFileSize(filePath: FolderDirPath))"
            InstalledSize.stringValue = "\(String(describing: output.substring(from: "Installed-Size: ", to: "\n", options: .caseInsensitive) ?? ""))"
            PackageAuthor.stringValue = "\(String(describing: output.substring(from: "Author: ", to: "\n", options: .caseInsensitive) ?? ""))"
            PackageMaintainer.stringValue = "\(String(describing: output.substring(from: "Maintainer: ", to: "\n", options: .caseInsensitive) ?? ""))"
            PackageArchitecture.stringValue = "\(String(describing: output.substring(from: "Architecture: ", to: "\n", options: .caseInsensitive) ?? ""))"
            PackageIcon.stringValue = "\(String(describing: output.substring(from: "Icon: ", to: "\n", options: .caseInsensitive) ?? ""))"
            Depends.stringValue = "\(String(describing: output.substring(from: "Depends:", to: "\n", options: .caseInsensitive) ?? ""))"
            Conflicts.stringValue = "\(String(describing: output.substring(from: "Conflicts: ", to: "\n", options: .caseInsensitive) ?? ""))"
            Replaces.stringValue = "\(String(describing: output.substring(from: "Replaces: ", to: "\n", options: .caseInsensitive) ?? ""))"
            Provides.stringValue = "\(String(describing: output.substring(from: "Provides: ", to: "\n", options: .caseInsensitive) ?? ""))"
            PackageDepiction.stringValue = "\(String(describing: output.substring(from: "Depiction: ", to: "\n", options: .caseInsensitive) ?? ""))"
            PackageSileoDepiction.stringValue = "\(String(describing: output.substring(from: "SileoDepiction: ", to: "\n", options: .caseInsensitive) ?? ""))"
            PackageFileName.stringValue = "\(String(describing: output.substring(from: "Filename: ", to: "\n", options: .caseInsensitive) ?? ""))"

        }
        
    }

    func shell(_ command: String) -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        
        return output
    }
    
    func dpkg_deb(_ path: String) -> String {
        let task = Process()
        task.launchPath = "/usr/local/bin/dpkg-deb"
        task.arguments = ["-e", path, Encrypt]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        
        return output
    }

    func GetFileSize(filePath:String) -> UInt64 {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let fileSize = fileAttributes[FileAttributeKey.size]  {
                return (fileSize as! NSNumber).uint64Value
            } else {
               // print("Failed to get a size attribute from path: \(filePath)")
            }
        } catch {
           // print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
        }
        return 0
    }
   @IBAction func follow(_ sender: Any) {
          let url = URL(string: "https://twitter.com/iiS4iF")!
          NSWorkspace.shared.open(url)
      }
    @IBAction func donate(_ sender: Any) {
           let url = URL(string: "https://paypal.me/iiS4iF")!
           NSWorkspace.shared.open(url)
       }
}


extension StringProtocol  {
    func substring(from start: Self, to end: Self? = nil, options: String.CompareOptions = []) -> SubSequence? {
        guard let lower = range(of: start, options: options)?.upperBound else { return nil }
        guard let end = end else { return self[lower...] }
        guard let upper = self[lower...].range(of: end, options: options)?.lowerBound else { return nil }
        return self[lower..<upper]
    }
}
