//
//  RsyncProcess.swift
//  ParseRsyncOutput
//
//  Created by Thomas Evensen on 07/09/2024.
//

import Foundation

@MainActor
final class RsyncProcess {
    var arguments: [String]?
    var processtermination: ([String]) -> Void
    var outputprocess: OutputfromProcess?

    let rsyncver3 = "/opt/homebrew/bin/rsync"
    let rsyncver2 = "/usr/bin/rsync"

    func executeProcess(_ ver3: Bool) {
        // Process
        let task = Process()
        if ver3 {
            task.launchPath = rsyncver3
        } else {
            task.launchPath = rsyncver2
        }
        task.arguments = arguments
        // Pipe for reading output from Process
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
        } catch {
            return
        }

        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)
        let strArray = output.components(separatedBy: "\n")
        processtermination(strArray)
    }

    init(arguments: [String]?,
         processtermination: @escaping ([String]) -> Void) {
        self.arguments = arguments
        self.processtermination = processtermination
        outputprocess = OutputfromProcess()
    }
}
