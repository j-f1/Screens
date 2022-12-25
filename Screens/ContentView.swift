//
//  ContentView.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var localModel = ViewModel(source: LocalScreenSource())
    @StateObject var sshModel = ViewModel(source: SSHScreenSource(username: "jed", host: "mini"))

    var body: some View {
        Menu("Click Me") {
            Section("Local") {
                ForEach(localModel.screens) { screen in
                    ScreenButton(screen: screen)
                }
            }
            Section("SSH: jed@mini") {
                ForEach(sshModel.screens) { screen in
                    ScreenButton(screen: screen)
                }
            }
        }
        .padding()
    }
}

struct ScreenButton: View {
    let screen: Screen

    private func runScript(_ script: String) -> NSDictionary? {
        let appleScript = NSAppleScript(source: """
            tell application "Terminal"
                activate
                do script "\(script)"
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
    }
}
