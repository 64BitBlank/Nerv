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

    func uploadToFirebase(field1: String, field2: String, field3: String, field4: String, field5: String, number: Int, field6: String) async throws {
        do {
            let json: [String: Any] = [
                "field1": field1,
                "field2": field2,
                "field3": field3,
                "field4": field4,
                "field5": field5,
                "number": number,
                "field6": field6
            ]
            // Assuming you have a collection named "requests" in Firestore
            try await Firestore.firestore().collection("requests").addDocument(data: json)
        } catch {
            print("Error encoding data: \(error.localizedDescription)")
        }
    }
}

