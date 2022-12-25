//
//  ContentView.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var model = ScreensProvider()
    func runScript(_ script: String) -> NSDictionary? {
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
        List(model.screens) { screen in
            HStack {
                Text(screen.name)
                Spacer()
                Text(String(screen.pid)).foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                if let error = runScript("screen -r \(screen.pid)") {
                    print(error)
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
