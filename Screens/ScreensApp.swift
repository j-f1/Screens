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
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        MenuBarExtra {
            ContentView()

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
            SettingsView()
                .frame(minWidth: 510)
                .onDisappear { appDelegate.config.save() }
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
