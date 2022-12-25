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
        Menu("Click Me") {
            ForEach(model.screens) { screen in
                Button {
                    if let error = runScript("screen -r \(screen.pid)") {
                        print(error)
                    }
                } label: {
                    Text(screen.name + (screen.status.label.map { " " + $0 } ?? ""))
                        .help(String(screen.pid))
                }.disabled(screen.status == .attached)
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
