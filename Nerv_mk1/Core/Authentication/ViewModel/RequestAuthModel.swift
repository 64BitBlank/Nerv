//
//  RequestAuthModel.swift
//  Nerv_mk1
//
//  Created by James Hallett on 14/11/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

@MainActor
class RequestAuthModel: ObservableObject {
    @Published var requests: [DocumentSnapshot] = []
    @Published var notifications = [NotificationsModel]()
    @Published var patientData: [String: Any]?
    let currentUser = AuthViewModel.shared.currentUser
    
    private var db = Firestore.firestore()
    
    // Centralized function for logging user actions
    // Access the shared instance of AuthViewModel to get the current user's ID
    // Builds log entry
    private func logUserAction(action: String) {
        if let currentUser = AuthViewModel.shared.currentUser {
            logActionForUser(userID: currentUser.id, action: action)
        } else {
            print("No current user available in RequestAuthModel.")
        }
    }

    private func logActionForUser(userID: String, action: String) {
        let logEntry = "\(action) - \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .long))"
        let userRef = db.collection("user").document(userID)
        
        userRef.updateData([
            "logs": FieldValue.arrayUnion([logEntry])
        ]) { error in
            if let error = error {
                print("Error logging user action: \(error.localizedDescription)")
            } else {
                print("User action logged successfully for userID: \(userID)")
            }
        }
    }

    func uploadToFirebase(field1: String, field2: String, field3: String, field4: String, field5: String, number: Int, field6: String, dateOfBirth: Date, sex: String, contactNumber: String, wardDesignation: String, medicalHistory: String, currentPrescriptions: String, newsScore: Int, nhsNumber: String) async throws {
        do {
            let json: [String: Any] = [
                "Forename": field1,
                "Lastname": field2,
                "altName": field3,
                "StaffNumber": field4,
                "Summary": field5,
                "number": number,
                "Additional": field6,
                "dob": dateOfBirth,
                "Sex": sex,
                "PersonalContact": contactNumber,
                "Ward": wardDesignation,
                "MedicalHistory": medicalHistory,
                "CurrentPerscription": currentPrescriptions,
                "isActive": false,
                "newsScore": newsScore,
                "nhsNumber": nhsNumber
            ]
            // Assuming you have a collection named "requests" in Firestore
            try await db.collection("requests").addDocument(data: json)
        } catch {
            print("Error encoding data: \(error.localizedDescription)")
        }
    }
    
    // Function to fetch all notifications in requests collection
    // Adapt to only seclect requests not assigned
    func fetchRequests(wards: [String]) async {
        do {
            // Fetch requests where 'isActive' is not true (or is absent)
            let querySnapshot = try await db.collection("requests")
                .whereField("isActive", isNotEqualTo: true)
                .getDocuments()

            // Filter the documents based on the wards array
            self.requests = querySnapshot.documents.filter { document in
                guard let requestWard = document.data()["Ward"] as? String else { return false }
                return wards.contains(requestWard)
            }
        } catch {
            print("Error fetching documents: \(error.localizedDescription)")
        }
    }

    
    // Function to add a reference to the user
    func addUserReference(documentID: String, userID: String) {
        let db = Firestore.firestore()
        
        // Start a batch
        let batch = db.batch()
        // Reference to the user's document where you want to add the patient reference
        let userRef = db.collection("user").document(userID)
        // Reference to the patient's document that you want to mark as active
        let patientRef = db.collection("requests").document(documentID)
        // Update the user's document with the new patient reference
        batch.updateData(["patientRef": documentID], forDocument: userRef)
        // Mark the patient as active
        batch.updateData(["isActive": true], forDocument: patientRef)
        
        // Commit the batch
        batch.commit { error in
            if let error = error {
                // Handle any errors
                print("Error writing batch: \(error)")
            } else {
                // Batch commit was successful
                print("Batch write succeeded, user and patient updated")
            }
        }
    }
    
    // fetches patient info via patientId from user collection
    func fetchPatientDetails(patientID: String) {
        let db = Firestore.firestore()
        let patientRef = db.collection("requests").document(patientID)

        patientRef.getDocument { (document, error) in
            if let document = document, document.exists {
                DispatchQueue.main.async {
                    self.patientData = document.data()
                }
            } else {
                print("Patient document does not exist")
            }
        }
    }
    // submit notes to firebase to be stored
    func addNotesToPatient(patientID: String, notes: String) {
            let db = Firestore.firestore()
            let patientRef = db.collection("requests").document(patientID)

            patientRef.updateData(["notes": notes]) { error in
                if let error = error {
                    // Handle any errors here
                    print("Error updating document: \(error)")
                } else {
                    // The document has been successfully updated
                    self.logUserAction(action: "Added/Updated notes to patient")
                    print("Document successfully updated")
                }
            }
        }
    
    // Storge image to firebase
    func uploadImageToFirebase(_ imageData: Data, withName title: String, patientRef: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let storageRef = Storage.storage().reference()
        let formattedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "_")
        let imageRef = storageRef.child("patient/\(patientRef)/\(formattedTitle).jpg")

        imageRef.putData(imageData, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
                completion(.failure(error ?? NSError(domain: "FirebaseStorageError", code: -1, userInfo: nil)))
                return
            }
            imageRef.downloadURL { url, error in
                if let url = url {
                    // Image uploaded successfully, now update Firestore
                    self.addPhotoURLToPatientDocument(url, patientRef: patientRef) { result in
                        completion(result)
                    }
                } else {
                    completion(.failure(error ?? NSError(domain: "FirebaseStorageError", code: -1, userInfo: nil)))
                }
            }
        }
    }
    // when uploading images to firestore add the urls for each to the array in patient to access later
    private func addPhotoURLToPatientDocument(_ url: URL, patientRef: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let db = Firestore.firestore()
        let patientDocument = db.collection("requests").document(patientRef)
        
        patientDocument.updateData([
            "photoRefs": FieldValue.arrayUnion([url.absoluteString])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(url))
                self.logUserAction(action: "Added image to patient")
            }
        }
    }
    
    // Testing functions - WIP (Doesn't work)
    func fetchNotifications() {
        db.collection("requests").addSnapshotListener { (querySnapshot, error) in
          guard let documents = querySnapshot?.documents else {
            print("No documents")
            return
          }

          self.notifications = documents.map { queryDocumentSnapshot -> NotificationsModel in
            let data = queryDocumentSnapshot.data()
            let Additional = data["Additional"] as? String ?? ""
            let Forename = data["Forename"] as? String ?? ""
            let Lastname = data["Lastname"] as? String ?? ""
            let StaffNumber = data["StaffNumber"] as? String ?? ""
            let Summary = data["Summary"] as? String ?? ""
            let altName = data["altName"] as? String ?? ""
            let number = data["number"] as? Int ?? 0

            return NotificationsModel(id: .init(), Additional: Additional, Forename: Forename, Lastname: Lastname, StaffNumber: StaffNumber, Summary: Summary, altName: altName, number: number)
          }
        }
      }
    // Testing functions - WIP (Doesn't work)
    func printNotifications() {
        for notification in notifications {
            print("ID: \(notification.id), Forename: \(notification.Forename), Lastname: \(notification.Lastname), Additional: \(notification.Additional), StaffNumber: \(notification.StaffNumber), Summary: \(notification.Summary), Alt Name: \(notification.altName), Number: \(notification.number)")
        }
    }
    
    
}

