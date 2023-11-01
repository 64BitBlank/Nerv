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
    @Published var currentUser: User?
    
    init() {
        
    }
    
    func signIn(withEmail email: String, password: String) async throws {
            print("Sign In...")
    }
    
    func creatUser(withEmail email:String, password: String, fullname: String) async throws {
        print("Create user..")
    }
    
    func signOut() {
        
    }
    
    func deleteAccount() {
        
    }
    
    func fetchUser() {
        
    }
}
