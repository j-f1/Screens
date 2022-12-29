//
//  ScreensApp.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-22.
//

import SwiftUI
import Combine

@main
struct ScreensApp: App {
    @State private var config = Config.load()
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        MenuBarExtra {
            ContentView(sources: config.sources)
                .environment(\.options, config.options)

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
            SettingsView(config: $config)
                .environment(\.options, config.options)
                .frame(minWidth: 510)
                .onDisappear(perform: config.save)
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
