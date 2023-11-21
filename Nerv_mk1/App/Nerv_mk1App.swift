//
//  Nerv_mk1App.swift
//  Nerv_mk1
//
//  Created by James Hallett on 31/10/2023.
//

import SwiftUI
import Firebase

@main
struct Nerv_mk1App: App {
    // make viewmodel accessable for every file instead of making stateObjects in every file
    @StateObject var viewModel = AuthViewModel()
    @StateObject var requestAuthModel = RequestAuthModel()
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(requestAuthModel)
            
        }
    }
}
