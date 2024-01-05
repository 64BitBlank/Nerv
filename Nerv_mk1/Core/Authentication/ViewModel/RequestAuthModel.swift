//
//  RequestAuthModel.swift
//  Nerv_mk1
//
//  Created by James Hallett on 14/11/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

@MainActor
class RequestAuthModel: ObservableObject {
    @Published var requests: [DocumentSnapshot] = []
    @Published var notifications = [NotificationsModel]()
    @Published var patientData: [String: Any]?
    
    private var db = Firestore.firestore()
    
    func uploadToFirebase(field1: String, field2: String, field3: String, field4: String, field5: String, number: Int, field6: String, dateOfBirth: Date, sex: String, contactNumber: String, wardDesignation: String, medicalHistory: String, currentPrescriptions: String) async throws {
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
                "isActive": false
            ]
            // Assuming you have a collection named "requests" in Firestore
            try await db.collection("requests").addDocument(data: json)
        } catch {
            print("Error encoding data: \(error.localizedDescription)")
        }
    }
    
    // Function to fetch all notifications in requests collection
    // Adapt to only seclect requests not assigned
    func fetchRequests() async {
        do {
            // Fetch requests where 'isActive' is not true (or is absent)
            let querySnapshot = try await db.collection("requests")
                .whereField("isActive", isNotEqualTo: true)
                .getDocuments()
            // Map the documents to your data model
            self.requests = querySnapshot.documents.map { $0 }
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

