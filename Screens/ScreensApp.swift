//
//  ScreensApp.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-22.
//

import SwiftUI

@main
struct ScreensApp: App {
    @State var sources: [SourceObserver] = [
        SourceObserver(source: LocalScreenSource()),
        SourceObserver(source: SSHScreenSource(username: "jed", host: "mini")),
    ]
    @Environment(\.openWindow) var openWindow
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
        }
        .windowToolbarStyle(.unifiedCompact)
        .windowResizability(.contentSize)
    }
}
