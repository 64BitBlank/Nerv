//
//  NavigationView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 07/11/2023.
////  NavigationView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 07/11/2023.
//

import SwiftUI

struct NavigationsView: View {
    @State private var showMenu: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main body for active tasks
                VStack {
                    // Top of page
                    HStack {
                        Text("Landing Page")
                            .font(.system(size: 24))
                            .padding(.top, 20)
                    }
                    Divider()
                        .padding()
                    Text("[Filler data here]")
                    Spacer()
                    //Middle of page
                    HStack {
                        Text("Middle")
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray3))
                            .padding(.horizontal, -170) // Subtract horizontal padding
                    )
                    .padding()
                    
                    Spacer()
                    Spacer()
                    // Bottom of page
                    Divider()
                        .padding()
                     HStack {
                         Spacer()
                         Text("Bottom")
                         Spacer()
                     }
                 
                    
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .blur(radius: showMenu ? 2 : 0) // Apply blur effect when showMenu is true
                .frame(maxWidth: .infinity)
                .background(Color(.white)) // Background color for the content
                
                GeometryReader { geometry in
                    HStack {
                        SideMenuView()
                            .offset(x: showMenu ? 0 : -geometry.size.width * 0.7)
                            .animation(.easeInOut(duration: 0.3), value: showMenu)
                    }
                }
                
                .background(Color.black.opacity(showMenu ? 0.7 : 0))
                .animation(.easeInOut(duration: 0.3), value: showMenu)
                
                // Top navigation bar with button (positioned in the top-left corner)
                GeometryReader { geometry in
                    VStack {
                        HStack {
                            Button(action: {
                                // When the button is pressed, toggle the showMenu state
                                self.showMenu.toggle()
                            }) {
                                // Change icon based on the showMenu state
                                if showMenu {
                                    Image(systemName: "xmark")
                                        .font(.title)
                                        .foregroundColor(.black)
                                        .offset(x: 10)
                                } else {
                                    Image(systemName: "text.justify")
                                        .font(.title)
                                        .foregroundColor(.black)
                                        .offset(x: 10)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationsView()
}
