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
    static let shared = AuthViewModel()
    // User logged in already?
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var patientRef: String? = nil
    @Published var patientRefs: [String] = []
    @Published var wards: [String] = []
    @Published var selectedWard: String = ""
    @Published var currentCarouselIndex: Int = 0
    
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
    func updateUserWards(wards: [String]){
        guard let userID = Auth.auth().currentUser?.uid else { return } // Get current user ID
        let db = Firestore.firestore()
        db.collection("user").document(userID).updateData(["wards": wards]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func fetchWards() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        do {
            let documentSnapshot = try await db.collection("user").document(userId).getDocument()
            // Directly check the existence without conditional binding
            if documentSnapshot.exists {
                self.wards = documentSnapshot.get("wards") as? [String] ?? []
            } else {
                print("Document does not exist")
            }
        } catch {
            print("Error fetching wards: \(error.localizedDescription)")
        }
    }
    func fetchPatientRefs() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        do {
            let documentSnapshot = try await db.collection("user").document(userId).getDocument()
            // Directly check the existence without conditional binding
            if documentSnapshot.exists {
                // Use the documentSnapshot directly since it's not optional
                self.patientRefs = documentSnapshot.get("patientRefs") as? [String] ?? []
            } else {
                print("Document does not exist")
            }
        } catch {
            print("Error fetching patient references: \(error.localizedDescription)")
        }
    }
    
    func removePatientRef(patientId: String) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User is not logged in")
            return
        }
        let db = Firestore.firestore()
        let userRef = db.collection("user").document(uid) // Use uid directly
        
        // Proceed with Firestore transaction
        do {
            try await db.runTransaction { transaction, errorPointer -> Any? in
                let userDocument: DocumentSnapshot
                do {
                    // Attempt to get the current user document using uid
                    userDocument = try transaction.getDocument(userRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                // Document contains the patientRefs field as an array
                guard var patientRefs = userDocument.get("patientRefs") as? [String] else {
                    return nil
                }
                
                // Remove the patientId if it exists in the array
                if let index = patientRefs.firstIndex(of: patientId) {
                    patientRefs.remove(at: index)
                } else {
                    // PatientId not found in the array, nothing to remove
                    return nil
                }
                // Update the patientRefs field with the modified array
                transaction.updateData(["patientRefs": patientRefs], forDocument: userRef)
                return nil
            }
            print("Patient reference removed successfully.")
        } catch let transactionError {
            print("A Firestore transaction error occurred: \(transactionError.localizedDescription)")
        }
    }
    
    func incrementDeathTally() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let userRef = db.collection("user").document(userId)
        
        do {
            // Fetch the current user document to get the current deathTally
            let documentSnapshot = try await userRef.getDocument()
            let currentTally = documentSnapshot.get("deathTally") as? Int ?? 0 // If deathTally doesn't exist, default to 0
            
            // Increment the deathTally by 1
            let updatedTally = currentTally + 1
            
            // Update the user document with the new deathTally
            try await userRef.updateData(["deathTally": updatedTally])
            print("Death tally updated successfully to \(updatedTally).")
        } catch {
            print("Error updating death tally: \(error.localizedDescription)")
        }
    }

}
