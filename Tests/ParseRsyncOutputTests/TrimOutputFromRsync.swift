//
//  TrimOutputFromRsync.swift
//  ParseRsyncOutput
//
//  Created by Thomas Evensen on 07/09/2024.
//

import Combine
import Foundation

enum Rsyncerror: LocalizedError {
    case rsyncerror

    var errorDescription: String? {
        switch self {
        case .rsyncerror:
            "There are errors in output from rsync"
        }
    }
}

@MainActor
final class TrimOutputFromRsync {
    var subscriptions = Set<AnyCancellable>()
    var trimmeddata = [String]()
    var errordiscovered: Bool = false

    // Error handling
    func checkforrsyncerror(_ line: String) throws {
        let error = line.contains("rsync error:")
        if error {
            throw Rsyncerror.rsyncerror
        }
    }

    init(_ data: [String]) {
        data.publisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    return
                case let .failure(error):
                    return
                }
            }, receiveValue: { [unowned self] line in
                if line.last != "/" {
                    trimmeddata.append(line)
                    do {
                        try checkforrsyncerror(line)
                    } catch let e {
                        // Only want one notification about error, not multiple
                        // Multiple can be a kind of race situation
                        if errordiscovered == false {
                            let error = e
                            errordiscovered = true
                        }
                    }
                }
            })
            .store(in: &subscriptions)
    }
}

