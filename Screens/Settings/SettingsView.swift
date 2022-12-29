//
//  SettingsView.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import SwiftUI
import Introspect

struct SettingsView: View {
    @Binding var sources: [SourceObserver]
    
    @State private var tab = Tab.sources
    private enum Tab {
        case sources
        case behavior
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $tab) {
                SettingsTabLabel("Sources", icon: "eye.fill", color: .indigo)
                    .badge(sources.count)
                    .tag(Tab.sources)
                SettingsTabLabel("Behavior", icon: "gearshape.fill", color: .purple)
                    .tag(Tab.behavior)
            }
            .navigationSplitViewColumnWidth(145)
        } detail: {
            Content(tab: tab, sources: $sources)
                .formStyle(.grouped)
                .navigationSplitViewColumnWidth(355)
        }
        .navigationSplitViewStyle(.prominentDetail)
    }
    
    private struct Content: View {
        let tab: Tab
        @Binding var sources: [SourceObserver]

        var body: some View {
            switch tab {
            case .sources:
                SourcesSettings(sources: $sources)
            case .behavior:
                BehaviorSettings()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(sources: .constant([]))
    }
}
