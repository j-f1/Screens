//
//  ContentView.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-22.
//

import SwiftUI

struct ContentView: View {
    let sources: [SourceObserver]

    var body: some View {
        ForEach(sources) { model in
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
    
    private func runScript(_ script: String) throws {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).command")
        try script.write(to: tempURL, atomically: false, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: NSNumber(value: 0o700)], ofItemAtPath: tempURL.path)
        NSWorkspace.shared.open(tempURL)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            try? FileManager.default.removeItem(at: tempURL)
        }
    }
    
    var body: some View {
        Button {
            do {
                try runScript(screen.command)
            } catch {
                NSAlert(error: error).runModal()
            }
        } label: {
            Text(screen.name + (screen.status.label.map { " " + $0 } ?? ""))
                .help(String(screen.pid))
        }.disabled(screen.status == .attached)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(sources: [.init(source: LocalScreenSource())])
    }
}
