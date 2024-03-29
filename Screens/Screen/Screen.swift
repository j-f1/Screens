//
//  Screen.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import Foundation

struct Screen: Identifiable, Sendable {
    let pid: pid_t
    let name: String
    let status: Status
    let source: AnyScreenSource
    
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
        source.command(for: self)
    }

    var baseCommand: String {
        "\(source.screenCommand) -r \(pid)"
    }
    
    fileprivate init?(source: some ScreenSource, name: some StringProtocol, status: some StringProtocol) {
        let splits = name.split(maxSplits: 1, omittingEmptySubsequences: false, whereSeparator: { $0 == "." })
        guard splits.count == 2 else { return nil }
        guard let pid = pid_t(splits[0]) else { return nil }
        self.pid = pid
        self.name = String(splits[1])
        guard let status = Status(rawValue: String(status)) else { return nil }
        self.status = status
        self.source = AnyScreenSource(source)
    }
    
    var id: pid_t {
        pid
    }
}

extension [Screen] {
    init?(source: some ScreenSource, screenOutput: String) {
        if screenOutput.starts(with: "No Sockets found in") {
            self = []
            return
        }
        let sections = screenOutput
            .split(separator: "\r\n")
        guard let content = sections.dropFirst().first else { return nil }
        self = content
            .split(separator: "\n")
            .dropLast()
            .map { $0.dropFirst().split(separator: "\t") }
            .compactMap { Screen(source: source, name: $0[0], status: $0[1]) }
    }
}

