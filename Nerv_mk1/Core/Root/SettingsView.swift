//
//  SettingsView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 07/11/2023.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $isDarkMode)
                    .onChange(of: isDarkMode) { _ in
                        // Toggle between light and dark mode when the switch changes
                        UIApplication.shared.windows.first?.rootViewController?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
                    }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
