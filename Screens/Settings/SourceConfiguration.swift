//
//  SourceConfiguration.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import SwiftUI

struct SourceConfiguration: View {
    @ObservedObject var model: SourceObserver
    let onDelete: () -> Void

    @State private var isDeleting = false

    func sourceBinding<T: ScreenSource>(for source: T) -> Binding<T> {
        Binding { source } set: { model.source = .init($0) }
    }

    var body: some View {
        Section {
            switch model.source.wrapped {
            case .local(let source): LocalSourceConfiguration(model: model, source: sourceBinding(for: source))
            case .ssh(let source): SSHSourceConfiguration(model: model, source: sourceBinding(for: source))
            }
        } header: {
            HStack {
                SourceTitle(
                    customTitle: $model.customTitle,
                    originalTitle: model.source.title
                )
                Spacer()
                Button("Delete…") { isDeleting = true }
                    .controlSize(.small)
                    .font(.caption2)
                    .confirmationDialog("Permanently delete “\(model.title)?”", isPresented: $isDeleting) {
                        Text("This action cannot be undone!")
                        Button("Delete", role: .destructive, action: onDelete)
                    }
            }
        }
    }
}

struct LocalSourceConfiguration: View {
    @ObservedObject var model: SourceObserver
    @Binding var source: LocalScreenSource

    var body: some View {
        LabeledContent("Type", value: "Local")
        MonospaceTextField("Command", text: Binding { source.screenCommand } set: { source = .init(screenCommand: $0) })
        SourceStatusDisplay(error: model.error, screenCount: model.screens.count)
    }
}

struct SSHSourceConfiguration: View {
    @ObservedObject var model: SourceObserver
    @Binding var source: SSHScreenSource

    var body: some View {
        LabeledContent("Type", value: "SSH")
        MonospaceTextField("Username", text: Binding { source.username } set: {
            source = .init(screenCommand: source.screenCommand, username: $0, host: source.host, port: source.port)
        })
        MonospaceTextField("Host", text: Binding { source.host } set: {
            source = .init(screenCommand: source.screenCommand, username: source.username, host: $0, port: source.port)
        })
        TextField("Port", value:  Binding { source.port } set: {
            source = .init(screenCommand: source.screenCommand, username: source.username, host: source.host, port: $0)
        }, format: .number)
        MonospaceTextField("Command", text: Binding { source.screenCommand } set: {
            source = .init(screenCommand: $0, username: source.username, host: source.host, port: source.port)
        })
        SourceStatusDisplay(error: model.error, screenCount: model.screens.count)
    }
}
