//
//  SourceStatusDisplay.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-29.
//

import SwiftUI

struct SourceStatusDisplay: View {
    let error: Error?
    let screenCount: Int
    
    var body: some View {
        if let error {
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
        } else if screenCount == 0 {
            Label("No active screens", systemImage: "info")
                .foregroundColor(.secondary)
                .font(.callout)
        } else {
            Label("Active screens: \(screenCount)", systemImage: "checkmark")
                .foregroundColor(.green)
                .brightness(-0.25)
                .font(.callout)
        }
    }
}

struct SourceStatusDisplay_Previews: PreviewProvider {
    static var previews: some View {
        SourceStatusDisplay(error: nil, screenCount: 0)
            .previewDisplayName("Empty")
        SourceStatusDisplay(error: nil, screenCount: 1)
            .previewDisplayName("1 screen")
        SourceStatusDisplay(error: nil, screenCount: 2)
            .previewDisplayName("2 screens")
        SourceStatusDisplay(error: ScreenError.exit(status: 42, output: "Hello, world!\nblah blah blah"), screenCount: 0)
            .previewDisplayName("exit error")
        SourceStatusDisplay(error: ScreenError.invalidContent("what even is a screen anyway"), screenCount: 0)
            .previewDisplayName("invalid content error")
    }
}
