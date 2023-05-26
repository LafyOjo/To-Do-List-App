//
//  SettingsView.swift
//  To-Do-List-App
//
//  Created by Isaiah Ojo on 26/04/2023.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("username") var username: String = "User"
    @AppStorage("theme") var theme: String = "light"
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    @AppStorage("fontSize") var fontSize: Int = 16
    
    @State private var newUsername = ""
    @State private var selectedThemeIndex = 0
    
    let themes = ["Light", "Dark"]
    let fontSizes = 14...22
    
    var body: some View {
        VStack {
            HStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            
            TextField("New Username", text: $newUsername)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
            
            Picker(selection: $selectedThemeIndex, label: Text("Theme")) {
                ForEach(themes.indices) { index in
                    Text(themes[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Toggle("Notifications", isOn: $notificationsEnabled)
                .padding()
            
            Stepper(value: $fontSize, in: fontSizes) {
                Text("Font Size: \(fontSize)")
            }
            .padding()
            
            Button(action: {
                if !newUsername.isEmpty {
                    username = newUsername
                }
                
                if selectedThemeIndex == 0 {
                    theme = "light"
                } else {
                    theme = "dark"
                }
                
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .font(.headline)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}
