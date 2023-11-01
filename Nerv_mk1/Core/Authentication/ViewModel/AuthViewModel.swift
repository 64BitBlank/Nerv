//
//  AuthViewModel.swift
//  Nerv_mk1
//
//  Created by James Hallett on 01/11/2023.
//

import Foundation
import Firebase

class AuthViewModel: ObservableObject {
    // User logged in already?
    @Published var userSession: FirebaseAuth.User?
    
}
