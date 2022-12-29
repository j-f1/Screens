//
//  SourcesSettings.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-29.
//

import SwiftUI

struct SourcesSettings: View {
    @Binding var sources: [SourceObserver]
    var body: some View {
        Form {
            ForEach(sources) { model in
                SourceConfiguration(model: model, onDelete: {
                    sources = sources.filter { $0.source != model.source }
                })
            }
            Section { } footer: {
                Text("Double-click a source name to rename it.\nClick \(Image(systemName: "plus")) above to add a new source.")
                    .imageScale(.small)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }.toolbar {
            Menu {
                Button("Local") {
                    sources.append(SourceObserver(source: LocalScreenSource()))
                }
                Button("SSH") {
                    sources.append(SourceObserver(source: SSHScreenSource(username: "", host: "")))
                }
            } label: {
                Label("Add Source", systemImage: "plus")
            }
        }.overlay {
            if sources.isEmpty {
                Text("No Sources")
                    .foregroundColor(.secondary)
                    .fixedSize()
            }
        }
    }
}

struct SourcesSettings_Previews: PreviewProvider {
    static var previews: some View {
        SourcesSettings(sources: .constant([]))
        SourcesSettings(sources: .constant([SourceObserver(source: LocalScreenSource())]))
    }
}
