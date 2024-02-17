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
    // previous unstructured versions
    @Published var requests: [DocumentSnapshot] = []
    @Published var notifications = [NotificationsModel]()
    @Published var patientData: [String: Any]?
    // new request objects
    @Published var requestDetails: [Request] = []
    @Published var newPatientData: Request?
    @Published var requestNotification: [Request] = []
    @Published var dismissalNotifications: [Request] = []
    
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
            let querySnapshot = try await db.collection("requests")
                .whereField("isActive", isNotEqualTo: true)
                .getDocuments()
            
            // Temporary array to hold the fetched requests
            var fetchedRequests: [Request] = []
            
            for document in querySnapshot.documents {
                guard let ward = document.data()["Ward"] as? String else { continue }
                
                if wards.contains(ward) {
                    let id = document.documentID
                    let ward = document.get("Ward") as? String ?? ""
                    let Additional = document.get("Additional") as? String ?? ""
                    let CurrentPrescription = document.get("CurrentPrescription") as? String ?? ""
                    let Forename = document.get("Forename") as? String ?? ""
                    let Lastname = document.get("Lastname") as? String ?? ""
                    let MedicalHistory = document.get("MedicalHistory") as? String ?? ""
                    let PersonalContact = document.get("PersonalContact") as? String ?? ""
                    let Sex = document.get("Sex") as? String ?? ""
                    let StaffNumber = document.get("StaffNumber") as? String ?? ""
                    let Summary = document.get("Summary") as? String ?? ""
                    let altName = document.get("altName") as? String ?? ""
                    let dob = document.get("dob") as? Timestamp ?? Timestamp()
                    let isActive = document.get("isActive") as? Bool ?? false
                    let notes = document.get("notes") as? String ?? ""
                    let number = document.get("number") as? Int ?? 0
                    let PhotoRefs = document.get("PhotoRefs") as? [String] ?? []
                    let newsScore = document.get("newsScore") as? Int ?? 0
                    let nhsNumber = document.get("nhsNumber") as? String ?? ""

                    // Create a Request object and add it to the fetchedRequests array
                    let request = Request(id: id, ward: ward, Additional: Additional, CurrentPerscription: CurrentPrescription, Forename: Forename, Lastname: Lastname, MedicalHistory: MedicalHistory, PersonalContact: PersonalContact, Sex: Sex, StaffNumber: StaffNumber, Summary: Summary, altName: altName, dob: dob, isActive: isActive, notes: notes, number: number, PhotoRefs: PhotoRefs, newsScore: newsScore, nhsNumber: nhsNumber)
                    fetchedRequests.append(request)
                }
            }
            
            // Assign the fetched requests to the published property
            DispatchQueue.main.async {
                self.requestNotification = fetchedRequests
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
    // update newPatientData when notes are altered
    func fetchUpdatedPatientDetails(by id: String) async {
        do {
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

                let request = Request(id: id, ward: ward, Additional: additional, CurrentPerscription: currentPrescription, Forename: forename, Lastname: lastname, MedicalHistory: medicalHistory, PersonalContact: personalContact, Sex: sex, StaffNumber: staffNumber, Summary: summary, altName: altName, dob: dob, isActive: isActive, notes: notes, number: number, PhotoRefs: photoRefs, newsScore: newsScore, nhsNumber: nhsNumber)

                DispatchQueue.main.async {
                    self.newPatientData = request
                    //print(self.newPatientData)
                }
            } else {
                print("Document does not exist")
                DispatchQueue.main.async {
                    self.newPatientData = nil
                }
            }
        } catch {
            print("Error fetching document: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.newPatientData = nil
            }
        }
    }
    
    // Mark patient as dead
    func markPatientAsDeceased(patientId: String) async {
        let db = Firestore.firestore()
        let patientRef = db.collection("requests").document(patientId)

        do {
            // Set the deceased field to true
            try await patientRef.updateData([
                "deceased": true
            ])
            print("Patient marked as deceased successfully.")
        } catch {
            print("Error marking patient as deceased: \(error.localizedDescription)")
        }
    }
    
    // Mark patient as dismissed (to be moved to dismissal
    func markPatientAsDismissed(patientId: String) async {
        let db = Firestore.firestore()
        let patientRef = db.collection("requests").document(patientId)

        do {
            // Set the deceased field to true
            try await patientRef.updateData([
                "toBeDismissed": true
            ])
            print("Patient marked as dismissed successfully.")
        } catch {
            print("Error marking patient as dismissed: \(error.localizedDescription)")
        }
    }
    
    // Add cause of death to the patients record
    func updatePatientDeathCause(patientId: String, deathCause: String) async {
        let db = Firestore.firestore()
        let patientRef = db.collection("requests").document(patientId) // Adjust the collection name as necessary

        do {
            // Update the patient document with the deathCause field
            try await patientRef.updateData([
                "deathCause": deathCause
            ])
            print("Patient's cause of death updated successfully.")
        } catch {
            print("Error updating patient's cause of death: \(error.localizedDescription)")
        }
    }
    
    // Changes patient ward & marks patient as non-active
    func updatePatientWard(patientId: String, wardSelection: String) async {
        let db = Firestore.firestore()
        let patientRef = db.collection("requests").document(patientId) // Adjust the collection name as necessary

        do {
            // Update the patient document with the new ward
            try await patientRef.updateData([
                "Ward": wardSelection,
                "isActive": false
            ])
            print("Patient's ward updated successfully to \(wardSelection).")
        } catch {
            print("Error updating patient's ward: \(error.localizedDescription)")
        }
    }
    
    // fetches every item where staff have set attribute to dismissed
    func fetchDismissalNotifications() async {
        do {
            let querySnapshot = try await db.collection("requests")
                .whereField("toBeDismissed", isEqualTo: true)
                .getDocuments()
            
            // Temporary array to hold the fetched requests
            var fetchedRequests: [Request] = []
            
            for document in querySnapshot.documents {
                let id = document.documentID
                let ward = document.get("Ward") as? String ?? ""
                let Additional = document.get("Additional") as? String ?? ""
                let CurrentPrescription = document.get("CurrentPrescription") as? String ?? ""
                let Forename = document.get("Forename") as? String ?? ""
                let Lastname = document.get("Lastname") as? String ?? ""
                let MedicalHistory = document.get("MedicalHistory") as? String ?? ""
                let PersonalContact = document.get("PersonalContact") as? String ?? ""
                let Sex = document.get("Sex") as? String ?? ""
                let StaffNumber = document.get("StaffNumber") as? String ?? ""
                let Summary = document.get("Summary") as? String ?? ""
                let altName = document.get("altName") as? String ?? ""
                let dob = document.get("dob") as? Timestamp ?? Timestamp(date: Date())
                let isActive = document.get("isActive") as? Bool ?? false
                let notes = document.get("notes") as? String ?? ""
                let number = document.get("number") as? Int ?? 0
                let PhotoRefs = document.get("PhotoRefs") as? [String] ?? []
                let newsScore = document.get("newsScore") as? Int ?? 0
                let nhsNumber = document.get("nhsNumber") as? String ?? ""
                
                let request = Request(id: id, ward: ward, Additional: Additional, CurrentPerscription: CurrentPrescription, Forename: Forename, Lastname: Lastname, MedicalHistory: MedicalHistory, PersonalContact: PersonalContact, Sex: Sex, StaffNumber: StaffNumber, Summary: Summary, altName: altName, dob: dob, isActive: isActive, notes: notes, number: number, PhotoRefs: PhotoRefs, newsScore: newsScore, nhsNumber: nhsNumber)
                fetchedRequests.append(request)
            }
            
            DispatchQueue.main.async {
                self.dismissalNotifications = fetchedRequests
            }
            
        } catch {
            print("Error fetching documents for dismissal: \(error.localizedDescription)")
        }
    }


}
