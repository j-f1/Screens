//
//  SettingsTabLabel.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-29.
//

import SwiftUI

struct SettingsTabLabel: View {
    let title: LocalizedStringKey
    let icon: String
    let color: Color
    
    init(_ title: LocalizedStringKey, icon: String, color: Color) {
        self.title = title
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        SwiftUI.Label {
            Text(title)
        } icon: {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 14, height: 14)
                .foregroundColor(.white)
                .padding(3)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(color.gradient)
                        .shadow(color: .black.opacity(0.1), radius: 0.5, y: 1)
                }
        }
    }
}

struct SettingsTabLabel_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SettingsTabLabel("Test", icon: "star.fill", color: .yellow)
            SettingsTabLabel("Test 2", icon: "minus", color: .indigo)
            SettingsTabLabel("Test 2", icon: "star.fill", color: .indigo)
        }
        .listStyle(.sidebar)
        .frame(width: 150)
    }
}
