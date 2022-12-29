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
        } else {
            Text(customTitle.isEmpty ? originalTitle : customTitle)
                .onTapGesture(count: 2) {
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
