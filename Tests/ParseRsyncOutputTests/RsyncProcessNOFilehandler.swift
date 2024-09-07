//
//  File.swift
//  ParseRsyncOutput
//
//  Created by Thomas Evensen on 07/09/2024.
//

import Foundation
import Combine

import Combine
import Foundation
import OSLog

@MainActor
final class RsyncProcessNOFilehandler {
    // Combine subscribers
    var subscriptons = Set<AnyCancellable>()
    // Arguments to command
    var arguments: [String]?
    // Process termination
    var processtermination: ([String]) -> Void
    // Output
    var outputprocess: OutputfromProcess?
    
    let rsyncver3 = "/opt/homebrew/bin/rsync"
    let rsyncver2 = "/usr/bin/rsync"

    func executeProcess() {
        // Process
        let task = Process()
        // Getting version of rsync
        task.launchPath = ""
        // Pipe for reading output from Process
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        // Combine, subscribe to NSNotification.Name.NSFileHandleDataAvailable
        NotificationCenter.default.publisher(
            for: NSNotification.Name.NSFileHandleDataAvailable)
            .sink { _ in
                let data = outHandle.availableData
                if data.count > 0 {
                    if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        self.outputprocess?.addlinefromoutput(str: str as String)
                    }
                    outHandle.waitForDataInBackgroundAndNotify()
                }
            }.store(in: &subscriptons)
        // Combine, subscribe to Process.didTerminateNotification
        NotificationCenter.default.publisher(
            for: Process.didTerminateNotification)
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { _ in
                // Process termination and Log to file
                self.processtermination(self.outputprocess?.getOutput() ?? [""])
                // Release Combine subscribers
                self.subscriptons.removeAll()
            }.store(in: &subscriptons)
        do {
            try task.run()
        } catch  {
            return
        }
    }

    init(arguments: [String]?,
         processtermination: @escaping ([String]) -> Void)
    {
        self.arguments = arguments
        self.processtermination = processtermination
        outputprocess = OutputfromProcess()
    }
}

// swiftlint:enable function_body_length cyclomatic_complexity line_length
