//
//  ScreensApp.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-22.
//

import SwiftUI

@main
struct ScreensApp: App {
    @State var models: [ViewModel] = [
        ViewModel(source: LocalScreenSource()),
        ViewModel(source: SSHScreenSource(username: "jed", host: "mini")),
    ]
    @Environment(\.openWindow) var openWindow
    var body: some Scene {
        MenuBarExtra {
            ContentView(models: models)
            Button("Settings…") {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "Settings")
            }.keyboardShortcut(",")
        } label: {
            Image(systemName: "terminal")
        }

        WindowGroup {
            ContentView(models: models)
        }
        
        Window("Screens Settings", id: "Settings") {
            SettingsView(models: $models)
        }
        .windowToolbarStyle(.unifiedCompact)
        .windowResizability(.contentSize)
    }
}
