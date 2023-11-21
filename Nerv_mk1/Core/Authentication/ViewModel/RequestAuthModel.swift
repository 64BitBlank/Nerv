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

    func uploadToFirebase(field1: String, field2: String, field3: String, field4: String, field5: String, number: Int, field6: String) async throws {
        do {
            let json: [String: Any] = [
                "Forename": field1,
                "Lastname": field2,
                "altName": field3,
                "StaffNumber": field4,
                "Summary": field5,
                "number": number,
                "Additional": field6
            ]
            // Assuming you have a collection named "requests" in Firestore
            try await Firestore.firestore().collection("requests").addDocument(data: json)
        } catch {
            print("Error encoding data: \(error.localizedDescription)")
        }
    }
    
    
    
    func fetchRequests() async {
        do {
            let querySnapshot = try await Firestore.firestore().collection("requests").getDocuments()
            self.requests = querySnapshot.documents.map { $0 }
        } catch {
            print("Error fetching documents: \(error.localizedDescription)")
        }
    }

    
    
}

