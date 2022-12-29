//
//  SourceTitle.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-29.
//

import SwiftUI

struct SourceTitle: View {
    @Binding var customTitle: String
    let originalTitle: String
    
    @State private var isEditing = false
    @State private var oldTitle = ""
    @FocusState private var textFieldFocused
    
    var body: some View {
        if isEditing {
            TextField("Custom Title", text: $customTitle, prompt: Text(originalTitle))
                .labelsHidden()
                .textFieldStyle(.plain)
                .font(.headline)
                .focused($textFieldFocused)
                .onAppear { textFieldFocused = true }
                .onSubmit { isEditing = false }
                .background(alignment: .trailing) {
                    Button("Cancel") {
                        isEditing = false
                        customTitle = oldTitle
                    }
                        .keyboardShortcut(.escape, modifiers: [])
                        .opacity(0)
                        .allowsHitTesting(false)
                }
                .onChange(of: textFieldFocused) { newValue in
                    if !newValue {
                        isEditing = false
                    }
                }
        } else {
            Text(customTitle.isEmpty ? originalTitle : customTitle)
                .onTapGesture(count: 2) {
                    oldTitle = customTitle
                    isEditing = true
                }
        }
    }
}

struct SourceTitle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            SourceTitle(customTitle: .constant(""), originalTitle: "Original")
            SourceTitle(customTitle: .constant("Custom"), originalTitle: "Original")
        }.padding()
    }
}
