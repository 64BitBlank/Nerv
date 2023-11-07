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
            Text("Menu")
                .font(.title)
                .foregroundColor(.black)
                .padding(.bottom, 20) // Add a small spacing (adjust the value as needed)
                
            NavigationLink{
                ProfileView()
                   // .navigationBarBackButtonHidden(true)
            }label: {
                Text("Profile")
                    .font(.title2)
                    .foregroundColor(.black)
                    .padding(.bottom, 10) // Add a small spacing (adjust the value as needed)
            }

            Spacer()
        }
        .padding(80)
        .background(Color(.white))
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    SideMenuView()
}
