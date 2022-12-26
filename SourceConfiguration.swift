//
//  SourceConfiguration.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import SwiftUI
import Socket
import Shout

struct SourceConfiguration: View {
    @ObservedObject var model: ViewModel
    let onDelete: () -> Void
    
    func sourceBinding<T: ScreenSource>(for source: T) -> Binding<T> {
        Binding { source } set: { model.source = .init($0) }
    }

    var body: some View {
        switch model.source.wrapped {
        case .local(let source): LocalSourceConfiguration(model: model, source: sourceBinding(for: source), onDelete: onDelete)
        case .ssh(let source): SSHSourceConfiguration(model: model, source: sourceBinding(for: source), onDelete: onDelete)
        }
    }
}

struct LocalSourceConfiguration: View {
    @ObservedObject var model: ViewModel
    @Binding var source: LocalScreenSource
    let onDelete: () -> Void

    var body: some View {
        SourceContainer {
            SourceTitle(title: model.source.title, onDelete: onDelete)
            LabeledTextField(label: "Command", placeholder: "screen", text: Binding { source.screenCommand } set: { source = .init(screenCommand: $0) })
            StatusDisplay(model: model)
        }
    }
}

struct SSHSourceConfiguration: View {
    @ObservedObject var model: ViewModel
    @Binding var source: SSHScreenSource
    let onDelete: () -> Void

    var body: some View {
        SourceContainer {
            SourceTitle(title: model.source.title, onDelete: onDelete)
            HStack {
                LabeledTextField(label: "Username", placeholder: "\(NSUserName())", text: Binding { source.username } set: {
                    source = .init(screenCommand: source.screenCommand, username: $0, host: source.host, port: source.port)
                })
                LabeledTextField(label: "Host", placeholder: "", text: Binding { source.host } set: {
                    source = .init(screenCommand: source.screenCommand, username: source.username, host: $0, port: source.port)
                })
//                LabeledTextField(label: "Port", placeholder: "22", text: Binding { source.username } set: {
//                    source = .init(screenCommand: source.screenCommand, username: $0, host: source.username, port: source.port)
//                })
            }
            LabeledTextField(label: "Command", placeholder: "screen", text: Binding { source.screenCommand } set: {
                source = .init(screenCommand: $0, username: source.username, host: source.host, port: source.port)
            })
            StatusDisplay(model: model)
        }
    }
}

struct SourceContainer<Content: View>: View {
    internal init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    let content: () -> Content
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8, content: content)
                .padding(8)
        }
    }
}

struct SourceTitle: View {
    let title: LocalizedStringKey
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(title).font(.headline)
            Spacer()
            Button("Delete", action: onDelete)
                .controlSize(.small)
        }
    }
}

struct LabeledTextField: View {
    let label: LocalizedStringKey
    let placeholder: LocalizedStringKey
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(placeholder, text: $text).font(.body.monospaced())
            Text(label).font(.caption)
        }

    }
}

struct StatusDisplay: View {
    @ObservedObject var model: ViewModel
    
    var body: some View {
        if let error = model.error {
            let desc: String = { desc in
                if desc.hasSuffix("\n") {
                    return String(desc.dropLast())
                }
                return desc
            }(error.localizedDescription)
            Text(desc)
                .foregroundColor(.red)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Label("Active screens: \(model.screens.count)", systemImage: "checkmark")
                .foregroundColor(.green)
                .brightness(-0.25)
                .font(.callout)
        }
    }
}

extension Socket.Error: LocalizedError {
    public var errorDescription: String? {
        description
    }
}

extension Shout.SSHError: LocalizedError {
    public var errorDescription: String? {
        description
    }
}
