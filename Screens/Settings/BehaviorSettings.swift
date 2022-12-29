//
//  BehaviorSettings.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-29.
//

import SwiftUI
import LaunchAtLogin

struct BehaviorSettings: View {
    @AppStorage("updateFrequency") private var updateFrequency = 1.0
    @AppStorage("hideEmpty") private var hideEmpty = false

    var body: some View {
        Form {
            TextField("Update frequency (sec)", value: $updateFrequency, format: .number)
            Toggle("Hide empty sources", isOn: $hideEmpty)
            LaunchAtLogin.Toggle()
        }
    }
}

struct BehaviorSettings_Previews: PreviewProvider {
    static var previews: some View {
        BehaviorSettings()
            .formStyle(.grouped)
            .frame(width: 400)
    }
}
