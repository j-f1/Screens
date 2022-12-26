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
    var body: some Scene {
//        MenuBarExtra {
//            ContentView()
//        } label: {
//            Image(systemName: "terminal")
//        }

        WindowGroup {
            ContentView(models: models)
        }
        
        Settings {
            SettingsView(models: $models)
        }
    }
}
