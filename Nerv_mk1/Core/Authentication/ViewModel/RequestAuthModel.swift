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
    @Published var requestDetails: [Request] = []
    
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
        
        // Reference to the user's document
        let userRef = db.collection("user").document(userID)
        // Reference to the request's document
        let requestRef = db.collection("requests").document(documentID)
        
        // Prepare to add the request ID to the photoRefs array in the user's document
        batch.updateData([
            "patientRefs": FieldValue.arrayUnion([documentID])
        ], forDocument: userRef)
        
        // Prepare to mark the request as active
        batch.updateData([
            "isActive": true
        ], forDocument: requestRef)
        
        // Commit the batch
        batch.commit { error in
            if let error = error {
                print("Error performing batch update: \(error)")
            } else {
                print("Batch update succeeded, request added to photoRefs and marked as active")
                self.logUserAction(action: "\(documentID) pinned to user")
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
    func fetchPatientWard(ids: [String]) async {
        var requests: [Request] = []
        
        do {
            for id in ids {
                let documentSnapshot = try await db.collection("requests").document(id).getDocument()
                // Directly check if the document exists, without using `if let` for optional binding.
                if documentSnapshot.exists, let data = documentSnapshot.data() {
                    let id = documentSnapshot.documentID
                    let ward = data["Ward"] as? String ?? ""
                    let additional = data["Additional"] as? String ?? ""
                    let currentPrescription = data["CurrentPerscription"] as? String ?? ""
                    let forename = data["Forename"] as? String ?? ""
                    let lastname = data["Lastname"] as? String ?? ""
                    let medicalHistory = data["MedicalHistory"] as? String ?? ""
                    let personalContact = data["PersonalContact"] as? String ?? ""
                    let sex = data["Sex"] as? String ?? ""
                    let staffNumber = data["StaffNumber"] as? String ?? ""
                    let summary = data["Summary"] as? String ?? ""
                    let altName = data["altName"] as? String ?? ""
                    let dob = data["dob"] as? Timestamp ?? Timestamp() 
                    let isActive = data["isActive"] as? Bool ?? false
                    let notes = data["notes"] as? String ?? ""
                    let number = data["number"] as? Int ?? 0
                    let photoRefs = data["photoRefs"] as? [String] ?? []
                    let newsScore = data["newsScore"] as? Int ?? 0
                    let nhsNumber = data["nhsNumber"] as? String ?? ""

                    // Assuming Request has an initializer that can handle all these fields.
                    let request = Request(id: id, ward: ward, Additional: additional, CurrentPerscription: currentPrescription, Forename: forename, Lastname: lastname, MedicalHistory: medicalHistory, PersonalContact: personalContact, Sex: sex, StaffNumber: staffNumber, Summary: summary, altName: altName, dob: dob, isActive: isActive, notes: notes, number: number, PhotoRefs: photoRefs, newsScore: newsScore, nhsNumber: nhsNumber)
                    requests.append(request)
                }
            }
            // Update the @Published property on the main thread
            DispatchQueue.main.async {
                self.requestDetails = requests
            }
        } catch {
            print("Error fetching documents: \(error.localizedDescription)")
        }
    }


}
// expand structure  later to hold all patient information rather then just id and ward
// for now this works to test data retieval & filtering
struct Request: Identifiable, Codable {
    let id: String
    let ward: String
    let Additional: String
    let CurrentPerscription: String
    let Forename: String
    let Lastname: String
    let MedicalHistory: String
    let PersonalContact: String
    let Sex: String
    let StaffNumber: String
    let Summary: String
    let altName: String
    let dob: Timestamp
    let isActive: Bool
    let notes: String
    let number: Int
    let PhotoRefs: Array<String>
    let newsScore: Int
    let nhsNumber: String
}
