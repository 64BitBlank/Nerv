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


            // Navigation link 1
            HStack{
                Image(systemName: "person.fill")
                NavigationLink{
                    ProfileView()
                }label: {
                    Text("Profile")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Text("")
                    .padding(.bottom, 20)
            }

            // Navigation link 2
            HStack{
                Image(systemName: "pencil.line")
                NavigationLink{
                    RequestView()
                }label: {
                    Text("Create Request")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Text("")
                    .padding(.bottom, 20)
            }

            // Navigation link 3
            HStack {
                Image(systemName: "bell")
                NavigationLink{
                            NotificationView()
                }label: {
                    Text("Notifications")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Text("")
                    .padding(.bottom, 20)
            }
            
            
            // Navigation link 4
            HStack {
                Image(systemName: "gear")
                NavigationLink{
                               SettingsView()
                }label: {
                    Text("Settings")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Text("")
                    .padding(.bottom, 20)
            }
            // Navigation link 4
            HStack {
                Image(systemName: "note")
                NavigationLink{
                               test()
                }label: {
                    Text("Development")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Text("")
                    .padding(.bottom, 20)
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
        
        
        
        .padding(45)
        .background(Color(.white))
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    SideMenuView()
}
