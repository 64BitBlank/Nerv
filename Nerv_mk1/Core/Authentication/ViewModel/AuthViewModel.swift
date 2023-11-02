//
//  AuthViewModel.swift
//  Nerv_mk1
//
//  Created by James Hallett on 01/11/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

 @MainActor
class AuthViewModel: ObservableObject {
    // User logged in already?
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    // When initilises, check if has a cached user and auto-login
    init() {
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
            print("Sign In...")
    }
    
    // Try create user with the firebase
    // Create user object with user details
    // Encode the user for Firebase storage
    // Store use in Firebase - id setup to allow fetching of user data for filling user profile page
    // Error catch if issues within the above process
    func creatUser(withEmail email:String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("user").document(user.id).setData(encodedUser)
            await fetchUser()
        }catch {
            print("ERROR: Failed to create a new User \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        }catch {
            print("DEBUG: Failed to sign user out \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("user").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
       // print("DEBUG: Current User is: \(self.currentUser)")
    }
}
