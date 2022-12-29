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
        case behavior
    }
    
    private struct Label: View {
        let title: LocalizedStringKey
        let icon: String
        let color: Color

        var body: some View {
            SwiftUI.Label {
                Text(title)
            } icon: {
                Image(systemName: icon)
                    .font(.system(size: 9))
                    .foregroundColor(.white)
                    .padding(3)
                    .background(color.gradient)
                    .cornerRadius(3)
                    .shadow(color: .black.opacity(0.1), radius: 1, y: 2)
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $tab) {
                Label(title: "Sources", icon: "tray.2", color: .gray)
                    .badge(models.count)
                    .tag(Tab.sources)
                Label(title: "Behavior", icon: "mail.and.text.magnifyingglass", color: .purple)
                    .tag(Tab.behavior)
            }
            .navigationSplitViewColumnWidth(145)
        } detail: {
            Content(tab: tab, models: $models)
                .formStyle(.grouped)
                .navigationSplitViewColumnWidth(355)
        }
        .navigationSplitViewStyle(.prominentDetail)
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
                        SwiftUI.Label("Add Source", systemImage: "plus")
                    }
                }
            case .behavior:
                Text("haha")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(models: .constant([]))
    }
}
