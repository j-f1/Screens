//
//  ScreensApp.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-22.
//

import SwiftUI
import Combine

let configURL = URL.homeDirectory
    .appendingPathComponent(".config")
    .appendingPathComponent("com.jedfox.screens", conformingTo: .json)

struct Config: Codable {
    let sources: [SourceObserver]
}

@main
struct ScreensApp: App {
    @State private var sources: [SourceObserver] = {
        do {
            return try JSONDecoder().decode(Config.self, from: try Data(contentsOf: configURL)).sources
        } catch {
            print(error)
            return []
        }
    }()
    @Environment(\.openWindow) private var openWindow

    @State private var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        return encoder
    }()
    
    func save() {
        do {
            let data = try encoder.encode(Config(sources: sources))
            try FileManager.default.createDirectory(at: configURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: configURL)
        } catch {
            print(error)
        }
    }
    
    var body: some Scene {
        MenuBarExtra {
            ContentView(sources: sources)

            Button("Settings…") {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "Settings")
            }.keyboardShortcut(",")

            Button("Quit") {
                NSApp.terminate(nil)
            }.keyboardShortcut("Q")
        } label: {
            Image(systemName: "terminal")
        }

        Window("Screens Settings", id: "Settings") {
            SettingsView(sources: $sources)
                .frame(minWidth: 510)
                .onDisappear(perform: save)
        }
        .windowToolbarStyle(.unifiedCompact)
        .windowResizability(.contentSize)
    }
}

extension Array where Element: ObservableObject {
    var objectsWillChange: some Publisher<Void, Never> {
        reduce(ObservableObjectPublisher().eraseToAnyPublisher()) { publisher, object in
            publisher.merge(with: object.objectWillChange.map { _ in Void() }).eraseToAnyPublisher()
        }
    }
}
