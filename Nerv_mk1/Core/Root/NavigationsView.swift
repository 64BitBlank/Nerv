//
//  NavigationView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 07/11/2023.
//

import SwiftUI

struct NavigationsView: View {
    @State private var showMenu: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack{
                GeometryReader { _ in
                    HStack {
                        SideMenuView()
                            .offset(x: showMenu ? 0 : -UIScreen.main.bounds.width)
                            .animation(.easeInOut(duration: 0.3), value:  showMenu)
                            
                    }
                }
                
                .background(Color.black.opacity(showMenu ? 0.7: 0))
                .animation(.easeInOut(duration: 0.3), value: showMenu)
                
                HStack {
                    // Main body for active tasks
                    Text("Content")
                        .blur(radius: showMenu ? 2 : 0) // Apply blur effect when showMenu is true
                    // Top navigation bar
                       // .navigationBarTitle("Landing Page", displayMode: .inline)
                        .navigationBarItems(leading: Button(action: {
                            // When button pressed toggle the GeomtryReader to show menu by altering bool value
                            self.showMenu.toggle()
                            
                        }) {
                            // When sidemenu open change icon to Close icon
                            if showMenu {
                                Image(systemName: "xmark")
                                    .font(.title)
                                    .foregroundColor(.black)
                                    .padding()
                            } else {
                                // When sidemenu not open use normal menu icon
                                Image(systemName: "text.justify")
                                    .font(.title)
                                    .foregroundColor(.black)
                                    .padding()
                            }
                           
                        })
                }
                
            }
        }
    }
}

#Preview {
    NavigationsView()
}
