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
        SourceContainer(model: model, onDelete: onDelete) {
            LabeledContent("Type", value: "Local")
            LabeledTextField(label: "Command", text: Binding { source.screenCommand } set: { source = .init(screenCommand: $0) })
            StatusDisplay(model: model)
        }
    }
}

struct SSHSourceConfiguration: View {
    @ObservedObject var model: ViewModel
    @Binding var source: SSHScreenSource
    let onDelete: () -> Void

    var body: some View {
        SourceContainer(model: model, onDelete: onDelete) {
            LabeledContent("Type", value: "SSH")
            LabeledTextField(label: "Username", text: Binding { source.username } set: {
                source = .init(screenCommand: source.screenCommand, username: $0, host: source.host, port: source.port)
            })
            LabeledTextField(label: "Host", text: Binding { source.host } set: {
                source = .init(screenCommand: source.screenCommand, username: source.username, host: $0, port: source.port)
            })
//            LabeledTextField(label: "Port", text: Binding { source.username } set: {
//                source = .init(screenCommand: source.screenCommand, username: $0, host: source.username, port: source.port)
//            })
            LabeledTextField(label: "Command", text: Binding { source.screenCommand } set: {
                source = .init(screenCommand: $0, username: source.username, host: source.host, port: source.port)
            })
            StatusDisplay(model: model)
        }
    }
}

struct SourceContainer<Content: View>: View {
    internal init(model: ViewModel, onDelete: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.model = model
        self.onDelete = onDelete
        self.content = content
    }
    
    let model: ViewModel
    let onDelete: () -> Void
    let content: () -> Content

    var body: some View {
        Section(content: content, header: {
            SourceTitle(model: model, onDelete: onDelete)
        })
//        GroupBox {
//            VStack(alignment: .leading, spacing: 8, content: content)
//                .padding(8)
//        }
    }
}

struct SourceTitle: View {
    @ObservedObject var model: ViewModel
    let onDelete: () -> Void
    @State private var isEditing = false
    @FocusState var textFieldFocused

    var body: some View {
        HStack {
            if isEditing {
                TextField("Custom Title", text: $model.customTitle, prompt: Text(model.source.title))
                    .labelsHidden()
                    .textFieldStyle(.plain)
                    .font(.headline)
                    .focused($textFieldFocused)
                    .onAppear {
                        textFieldFocused = true
                    }
                    .onSubmit {
                        isEditing = false
                    }
            } else {
                Text(model.title)
                    .onTapGesture(count: 2) {
                        isEditing = true
                    }
            }
            Spacer()
            Button("Delete", action: onDelete)
                .controlSize(.small)
                .font(.caption)
        }
    }
}

struct LabeledTextField: View {
    let label: LocalizedStringKey
    @Binding var text: String
    
    var body: some View {
        TextField(text: $text) {
            Text(label).font(.body)
        }.font(.body.monospaced())
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
            let splits = desc.split(separator: "\n", maxSplits: 1)
            VStack(alignment: .leading, spacing: 8) {
                Label(splits.first!, systemImage: "exclamationmark.octagon.fill")
                    .foregroundColor(.red)
                if splits.count > 1 {
                    Text(splits[1])
                        .monospaced()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }.textSelection(.enabled)
        } else if model.screens.isEmpty {
            Label("No active screens", systemImage: "info")
                .foregroundColor(.secondary)
                .font(.callout)
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
