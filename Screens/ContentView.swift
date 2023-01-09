//
//  ContentView.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appDelegate: AppDelegate

    var body: some View {
        ForEach(appDelegate.config.sources) { model in
            ModelSection(model: model)
        }
    }
}

struct ModelSection: View {
    @ObservedObject var model: SourceObserver

    @Environment(\.options) private var options

    var body: some View {
        if model.error != nil {
            Section("\(model.title) — Error") {
                Text("Open Settings to debug")
            }
        } else if model.screens.isEmpty {
            if !options.hideEmpty {
                Section("\(model.title) — No Active Screens") {}
            }
        } else {
            Section(model.title) {
                ForEach(model.screens) { screen in
                    ScreenButton(screen: screen)
                }
            }
        }
    }
}

struct ScreenButton: View {
    let screen: Screen

    private func runScript(_ script: String) -> NSDictionary? {
        let appleScript = NSAppleScript(source: """
            tell application "Terminal"
                activate
                do script "\(script) && exit"
            end tell
        """)!
        var error: NSDictionary?
        appleScript.executeAndReturnError(&error)
        return error
    }
    
    var body: some View {
        Button {
            if let error = runScript(screen.command) {
                print(error)
            }
        } label: {
            Text(screen.name + (screen.status.label.map { " " + $0 } ?? ""))
                .help(String(screen.pid))
        }.disabled(screen.status == .attached)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppDelegate(config: Config(sources: [.init(source: LocalScreenSource())])))
    }
}
