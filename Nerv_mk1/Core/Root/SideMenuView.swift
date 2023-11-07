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
                .font(.title2)
                .foregroundColor(.black)

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
