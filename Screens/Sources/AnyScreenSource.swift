//
//  AnyScreenSource.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import Foundation

final class AnyScreenSource: ScreenSource {
    init(_ source: any ScreenSource) {
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

        var type: WrappedType {
            switch self {
            case .local: return .local
            case .ssh: return .ssh
            }
        }
        var value: any ScreenSource {
            switch self {
            case .local(let source): return source
            case .ssh(let source): return source
            }
        }
    }
    enum WrappedType: String, Codable {
        case local
        case ssh
        
        var type: any ScreenSource.Type {
            switch self {
            case .local: return LocalScreenSource.self
            case .ssh: return SSHScreenSource.self
            }
        }
    }

    // MARK: ScreenSource

    func update() async throws -> [Screen] {
        try await wrapped.value.update()
    }
    func command(for screen: Screen) -> String {
        wrapped.value.command(for: screen)
    }
    var screenCommand: String {
        wrapped.value.screenCommand
    }
    var title: String {
        wrapped.value.title
    }

    // MARK: (non) Codable

    init(from decoder: Decoder) throws {
        throw DecodingError.dataCorrupted(.init(
            codingPath: decoder.codingPath,
            debugDescription: "Cannot explicitly decode an AnyScreenSource"
        ))
    }
    
    func encode(to encoder: Encoder) throws {
        throw EncodingError.invalidValue(self, .init(
            codingPath: encoder.codingPath,
            debugDescription: "Cannot explicitly encode an AnyScreenSource"
        ))
    }

    // MARK: Hashable/Equatable

    static func == (lhs: AnyScreenSource, rhs: AnyScreenSource) -> Bool {
        lhs.wrapped == rhs.wrapped
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrapped)
    }
}
