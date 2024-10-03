//
//  TrimOutput.swift
//  ParseRsyncOutput
//
//  Created by Thomas Evensen on 03/10/2024.
//

import Combine
import Foundation

@available(macOS 10.15, *)
@MainActor
final class TrimOutput {
    var subscriptions = Set<AnyCancellable>()
    var trimmeddata = [String]()

    init(_ data: [String]) {
        data.publisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    return
                case .failure:
                    return
                }
            }, receiveValue: { [unowned self] line in
                if line.last != "/" {
                    trimmeddata.append(line)
                }
            })
            .store(in: &subscriptions)
    }
}
