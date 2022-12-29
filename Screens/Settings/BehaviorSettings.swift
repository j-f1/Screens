//
//  BehaviorSettings.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-29.
//

import SwiftUI
import LaunchAtLogin

struct BehaviorSettings: View {
    @Binding var options: Config.Options

    var body: some View {
        Form {
            TextField("Update frequency (sec)", value: $options.updateFrequency, format: .number)
            Toggle("Hide empty sources", isOn: $options.hideEmpty)
            LaunchAtLogin.Toggle()
        }
    }
}

struct BehaviorSettings_Previews: PreviewProvider {
    static var previews: some View {
        BehaviorSettings(options: .constant(Config.Options()))
            .formStyle(.grouped)
            .frame(width: 400)
    }
}
