//
//  ContentView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 31/10/2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                ProfileView()
            }else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}
