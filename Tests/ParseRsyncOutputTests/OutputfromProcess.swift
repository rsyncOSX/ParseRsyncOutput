//
//  OutputfromProcess.swift
//  ParseRsyncOutput
//
//  Created by Thomas Evensen on 07/09/2024.
//

import Foundation

final class OutputfromProcess {
    private var output: [String]?

    func getOutput() -> [String]? {
        output
    }

    func addlinefromoutput(str: String) {
        str.enumerateLines { line, _ in
            self.output?.append(line)
        }
    }

    init() {
        output = [String]()
    }
}
