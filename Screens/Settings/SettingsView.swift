//
//  SettingsView.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import SwiftUI
import Introspect

struct SettingsView: View {
    @Binding var config: Config
    
    @State private var tab = Tab.sources
    private enum Tab {
        case sources
        case behavior
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $tab) {
                SettingsTabLabel("Sources", icon: "eye.fill", color: .indigo)
                    .badge(config.sources.count)
                    .tag(Tab.sources)
                SettingsTabLabel("Behavior", icon: "gearshape.fill", color: .purple)
                    .tag(Tab.behavior)
            }
            .navigationSplitViewColumnWidth(145)
        } detail: {
            Content(tab: tab, config: $config)
                .formStyle(.grouped)
                .navigationSplitViewColumnWidth(355)
        }
        .navigationSplitViewStyle(.prominentDetail)
    }
    
    private struct Content: View {
        let tab: Tab
        @Binding var config: Config

        var body: some View {
            switch tab {
            case .sources:
                SourcesSettings(sources: $config.sources)
            case .behavior:
                BehaviorSettings(options: $config.options)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(config: .constant(Config()))
    }
}
