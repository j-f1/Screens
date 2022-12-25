//
//  Screen.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import Foundation

struct Screen: Identifiable {
    let pid: pid_t
    let name: String
    let status: Status
    
    enum Status: String {
        case detached = "(Detached)"
        case attached = "(Attached)"
        
        var label: String? {
            switch self {
            case .detached: return nil
            default: return rawValue
            }
        }
    }
    
    var command: String {
        "screen -r \(pid)"
    }
    
    fileprivate init?(name: some StringProtocol, status: some StringProtocol) {
        let splits = name.split(maxSplits: 1, omittingEmptySubsequences: false, whereSeparator: { $0 == "." })
        guard splits.count == 2 else { return nil }
        guard let pid = pid_t(splits[0]) else { return nil }
        self.pid = pid
        self.name = String(splits[1])
        guard let status = Status(rawValue: String(status)) else { return nil }
        self.status = status
    }
    
    var id: pid_t {
        pid
    }
}

extension [Screen] {
    init(screenOutput: String) {
        self = screenOutput
            .split(separator: "\r\n")[1]
            .split(separator: "\n")
            .dropLast()
            .map { $0.dropFirst().split(separator: "\t") }
            .compactMap { Screen(name: $0[0], status: $0[1]) }
    }
}

