//
//  SettingsView.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import SwiftUI

struct SettingsView: View {
    @Binding var models: [ViewModel]
    
    var body: some View {
        VStack {
            ForEach(models) { model in
                SourceConfiguration(model: model, onDelete: {
                    models = models.filter { $0.source != model.source }
                })
            }
        }
        .frame(width: 300)
        .padding()
    }
}
