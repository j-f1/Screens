//
//  ScreenSource.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import Foundation

protocol ScreenSource: Hashable {
    func update() async throws -> [Screen]
}

extension ScreenSource {
    var any: AnyScreenSource {
        if let any = self as? AnyScreenSource {
            return any
        } else if let local = self as? LocalScreenSource {
            return .local(local)
        } else {
            fatalError("Invalid ScreenSource type \(Self.self)")
        }
    }
}

enum AnyScreenSource: ScreenSource {
    case local(LocalScreenSource)

    func update() async throws -> [Screen] {
        switch self {
        case .local(let local): return try await local.update()
        }
    }
}
