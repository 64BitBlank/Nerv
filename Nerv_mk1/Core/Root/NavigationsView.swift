//
//  NavigationView.swift
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
                HStack {
                    // Main body for active tasks
                    Text("Content")
                        .blur(radius: showMenu ? 2 : 0) // Apply blur effect when showMenu is true
                        .frame(maxWidth: .infinity)
                        .background(Color.white) // Background color for the content
                }

                GeometryReader { geometry in
                    HStack {
                        SideMenuView()
                            .offset(x: showMenu ? 0 : -geometry.size.width * 0.7)
                            .animation(.easeInOut(duration: 0.3), value: showMenu)
                    }
                }

                .background(Color.black.opacity(showMenu ? 0.7: 0))
                .animation(.easeInOut(duration: 0.3), value: showMenu)

                // Top navigation bar with button (positioned in the top-left corner)
                GeometryReader { geometry in
                    VStack {
                        Button(action: {
                            // When button is pressed, toggle the GeometryReader to show the menu by altering the bool value
                            self.showMenu.toggle()
                        }) {
                            // Change icon based on the showMenu state
                            if showMenu {
                                Image(systemName: "xmark")
                                    .font(.title)
                                    .foregroundColor(.black)
                                    .padding()
                            } else {
                                Image(systemName: "text.justify")
                                    .font(.title)
                                    .foregroundColor(.black)
                                    .padding()
                            }
                        }
                        .alignmentGuide(.leading) { d in d[.leading] }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    NavigationsView()
}
