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
            wrapped = source.wrapped
        } else if let source = source as? LocalScreenSource {
            wrapped = .local(source)
        } else if let source = source as? SSHScreenSource {
            wrapped = .ssh(source)
        } else {
            fatalError("Invalid ScreenSource type \(Self.self)")
        }
    }
    let wrapped: Wrapped
    enum Wrapped: Hashable {
        case local(LocalScreenSource)
        case ssh(SSHScreenSource)
    }
    
    static func == (lhs: AnyScreenSource, rhs: AnyScreenSource) -> Bool {
        lhs.wrapped == rhs.wrapped
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrapped)
    }

    func update() async throws -> [Screen] {
        switch wrapped {
        case .local(let local): return try await local.update()
        case .ssh(let ssh): return try await ssh.update()
        }
    }
    
    func command(for screen: Screen) -> String {
        switch wrapped {
        case .local(let local):
            return local.command(for: screen)
        case .ssh(let ssh):
            return ssh.command(for: screen)
        }
    }
}
