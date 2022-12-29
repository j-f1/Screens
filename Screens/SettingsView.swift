//
//  SettingsView.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import SwiftUI
import Introspect

struct SettingsView: View {
    @Binding var models: [ViewModel]
    
    @State private var tab = Tab.sources
    private enum Tab {
        case sources
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.doubleColumn)) {
            List(selection: $tab) {
                Label("Sources", systemImage: "tray.2.fill").tag(Tab.sources)
            }
            .navigationSplitViewColumnWidth(145)
        } detail: {
            Content(tab: tab, models: $models)
                .formStyle(.grouped)
                .navigationSplitViewColumnWidth(355)
        }
        .frame(width: 500)
        .navigationSplitViewStyle(.prominentDetail)
        .introspect(selector: { $0 }) { view in
            if let toolbar = view.window?.toolbar,
               let toggleIdx = toolbar.items.firstIndex(where: { $0.itemIdentifier.rawValue.contains("toggleSidebar") }) {
                toolbar.removeItem(at: toggleIdx)
            }
        }
    }
    
    private struct Content: View {
        let tab: Tab
        @Binding var models: [ViewModel]

        var body: some View {
            switch tab {
            case .sources:
                Form {
                    ForEach(models) { model in
                        SourceConfiguration(model: model, onDelete: {
                            models = models.filter { $0.source != model.source }
                        })
                    }
                }.toolbar {
                    Menu {
                        Button("Local") {
                            models.append(ViewModel(source: LocalScreenSource()))
                        }
                        Button("SSH") {
                            models.append(ViewModel(source: SSHScreenSource(username: "", host: "")))
                        }
                    } label: {
                        Label("Add Source", systemImage: "plus")
                    }

                }
            }
        }
    }
}
