//
//  SourceObserver.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-22.
//

import Foundation
import SwiftUI

@MainActor
class SourceObserver: ObservableObject, Identifiable, Equatable, Codable {
    // persisted
    @Published var source: AnyScreenSource
    @Published var customTitle: String = ""

    var title: String {
        customTitle.isEmpty ? source.title : customTitle
    }

    // not persisted
    @Published var screens = [Screen]()
    @Published var error: Error?

    init(source: any ScreenSource) {
        self.source = AnyScreenSource(source)
    }

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(AnyScreenSource.WrappedType.self, forKey: .type)
        self.init(source: try container.decode(type.type, forKey: .options))
        self.customTitle = try container.decode(String.self, forKey: .customTitle)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(source.wrapped.type, forKey: .type)
        try container.encode(source.wrapped.value, forKey: .options)
        try container.encode(customTitle, forKey: .customTitle)
    }
    
    private enum CodingKeys: CodingKey {
        case type
        case options
        case customTitle
    }
    
    func update() {
        Task {
            do {
                let screens = try await source.update()
                await MainActor.run {
                    self.screens = screens
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
    
    nonisolated static func == (lhs: SourceObserver, rhs: SourceObserver) -> Bool {
        lhs === rhs
    }
}
