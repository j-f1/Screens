//
//  ScreenSource.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import Foundation

protocol ScreenSource: AnyObject, Hashable {
    func update() async throws -> [Screen]
    func command(for screen: Screen) -> String
}

class AnyScreenSource: ScreenSource {
    init(_ source: some ScreenSource) {
        if let source = source as? AnyScreenSource {
            value = source.value
        } else if let source = source as? LocalScreenSource {
            value = .local(source)
        } else if let source = source as? SSHScreenSource {
            value = .ssh(source)
        } else {
            fatalError("Invalid ScreenSource type \(Self.self)")
        }
    }
    private let value: Value
    private enum Value: Hashable {
        case local(LocalScreenSource)
        case ssh(SSHScreenSource)
    }
    
    static func == (lhs: AnyScreenSource, rhs: AnyScreenSource) -> Bool {
        lhs.value == rhs.value
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }

    func update() async throws -> [Screen] {
        switch value {
        case .local(let local): return try await local.update()
        case .ssh(let ssh): return try await ssh.update()
        }
    }
    
    func command(for screen: Screen) -> String {
        switch value {
        case .local(let local):
            return local.command(for: screen)
        case .ssh(let ssh):
            return ssh.command(for: screen)
        }
    }
}
