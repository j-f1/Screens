//
//  Config.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-29.
//

import SwiftUI

struct Config: Codable {
    var options = Options()
    var sources = Array<SourceObserver>()
    
    struct Options: Codable {
        var hideEmpty = false
        var updateFrequency: TimeInterval = 1.0
    }
    
    static let configURL = URL.homeDirectory
        .appendingPathComponent(".config")
        .appendingPathComponent("com.jedfox.screens", conformingTo: .json)
    
    static func load() -> Self {
        do {
            return try JSONDecoder().decode(Self.self, from: try Data(contentsOf: configURL))
        } catch {
            print(error)
            return Config()
        }
    }
    
    private static var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        return encoder
    }()
    
    var encoded: Data {
        get throws {
            try Self.encoder.encode(self)
        }
    }
    func save() {
        do {
            try FileManager.default.createDirectory(at: Self.configURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try encoded.write(to: Self.configURL)
        } catch {
            print(error)
        }
    }
}

extension EnvironmentValues {
    private struct OptionsKey: EnvironmentKey {
        static var defaultValue = Config.Options()
    }
    var options: Config.Options {
        get { self[OptionsKey.self] }
        set { self[OptionsKey.self] = newValue }
    }
}
