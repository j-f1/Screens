//
//  MonospaceTextField.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-29.
//

import SwiftUI

struct MonospaceTextField: View {
    let label: LocalizedStringKey
    @Binding var text: String
    
    init(_ label: LocalizedStringKey, text: Binding<String>) {
        self.label = label
        self._text = text
    }
    
    var body: some View {
        TextField(text: $text) {
            Text(label).font(.body)
        }.font(.body.monospaced())
    }
}

struct MonospaceTextField_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            MonospaceTextField("Test", text: .constant(""))
            MonospaceTextField("Test", text: .constant("hello"))
        }
        .formStyle(.grouped)
        .previewLayout(.fixed(width: 300, height: 300))
    }
}
