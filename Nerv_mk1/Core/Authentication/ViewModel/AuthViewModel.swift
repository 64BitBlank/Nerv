//
//  AuthViewModel.swift
//  Nerv_mk1
//
//  Created by James Hallett on 01/11/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol AuthenticationFromProtocol {
    var formIsValid: Bool { get }
}

 @MainActor
class AuthViewModel: ObservableObject {
    // User logged in already?
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var patientRef: String? = nil
    
    // When initilises, check if has a cached user and auto-login
    init() {
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchUser()
            
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("ERROR: Failed to login \(error.localizedDescription)")
        }
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
            let user = User(id: result.user.uid, fullname: fullname, email: email, patientRef: "")
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("user").document(user.id).setData(encodedUser)
            await fetchUser()
        }catch {
            print("ERROR: Failed to create a new User \(error.localizedDescription)")
        }
    }
    
    // Sign user on backend
    // Wipes user session & takes back to login page
    // Wipes current user model so user data isnt retained inside app after signout
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        }catch {
            print("ERROR: Failed to sign user out \(error.localizedDescription)")
        }
    }
    
    // Decode json data from backend to user object
    // Assign data to currentUser
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("user").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        fetchPatientRef()
       // print("DEBUG: Current User is: \(self.currentUser)")
    }
    
    func fetchPatientRef() {
        // method to get the current userID
        guard let userID = currentUser?.id else { return }
        
        // Fetch user's patientRef from Firebase
        fetchUserPatientRef(userID: userID) { patientRef in
            DispatchQueue.main.async {
                self.patientRef = patientRef
            }
        }
    }
    
    func fetchUserPatientRef(userID: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("user").document(userID)

        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let patientRef = document.data()?["patientRef"] as? String
                completion(patientRef)
            } else {
                print("User document does not exist")
                completion(nil)
            }
        }
    }
    
    
}
