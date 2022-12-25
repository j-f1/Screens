//
//  ScreenSource.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import Foundation

protocol ScreenSource: Hashable {
    func update() async throws -> [Screen]
    func command(for screen: Screen) -> String
}

extension ScreenSource {
    var erased: AnyScreenSource {
        if let any = self as? AnyScreenSource {
            return any
        } else if let local = self as? LocalScreenSource {
            return .local(local)
        } else if let ssh = self as? SSHScreenSource {
            return .ssh(ssh)
        } else {
            fatalError("Invalid ScreenSource type \(Self.self)")
        }
    }
}

enum AnyScreenSource: ScreenSource {
    case local(LocalScreenSource)
    case ssh(SSHScreenSource)

    func update() async throws -> [Screen] {
        switch self {
        case .local(let local): return try await local.update()
        case .ssh(let ssh): return try await ssh.update()
        }
    }
    
    func command(for screen: Screen) -> String {
        switch self {
        case .local(let local):
            return local.command(for: screen)
        case .ssh(let ssh):
            return ssh.command(for: screen)
        }
    }
}
