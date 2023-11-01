//
//  RegistrationView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 01/11/2023.
//

import SwiftUI

struct RegistrationView: View {
    var body: some View {
        VStack {
            Image("Nerv_logo")
                .resizable()
                .scaledToFill()
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 120)
                .padding(.vertical, 32)
        }
    }
}

#Preview {
    RegistrationView()
}
