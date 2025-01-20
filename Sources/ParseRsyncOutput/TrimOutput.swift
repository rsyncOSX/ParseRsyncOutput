//
//  TrimOutput.swift
//  ParseRsyncOutput
//
//  Created by Thomas Evensen on 03/10/2024.
//

import Foundation


@MainActor
final class TrimOutput {
    var trimmeddata: [String]?

    init(_ data: [String]) {
        trimmeddata = data.compactMap({ line in
            return ((line.last != "/")) ? line : nil
        })
    }
}
