//
//  SideMenuView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 07/11/2023.
//

import SwiftUI

struct SideMenuView: View {
    var body: some View {
        VStack {
            // Header for sidemenu
            Text("Menu")
                .font(.title)
                .foregroundColor(.black)
                .padding(.bottom, 20) // Add a small spacing
//            Divider()

            
            // Navigation link 1
            NavigationLink{
                ProfileView()
            }label: {
                Text("Profile")
                    .font(.title2)
                    .foregroundColor(.black)
                    .padding(.bottom, 10) // Add a small spacing
            }
            
            // Navigation link 2
            NavigationLink{
                SettingsView()
            }label: {
                Text("Settings")
                    .font(.title2)
                    .foregroundColor(.black)
                    .padding(.bottom, 10) // Add a small spacing
            }
            

            Spacer()
            // image
            Image("Nerv_logo")
                .resizable()
                .scaledToFill()
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 120)
                .padding(.vertical, -10)
            Text("Hallett")
                .font(.title3)
                .foregroundColor(Color(.systemGray))
        }
        
        
        
        .padding(80)
        .background(Color(.white))
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    SideMenuView()
}
