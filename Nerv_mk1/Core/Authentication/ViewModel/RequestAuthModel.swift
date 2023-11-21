//
//  RequestAuthModel.swift
//  Nerv_mk1
//
//  Created by James Hallett on 14/11/2023.
//

import Foundation
import Firebase

struct RequestModelUploader {

    static func uploadToFirebase(requestModel: RequestModel) {
        let db = Firestore.firestore()

        do {
            let jsonData = try JSONEncoder().encode(requestModel)
            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] ?? [:]

            // Assuming you have a collection named "requests" in Firestore
            db.collection("requests").addDocument(data: json) { error in
                if let error = error {
                    print("Error adding document to Firestore: \(error.localizedDescription)")
                } else {
                    print("Document added to Firestore successfully")
                }
            }
        } catch {
            print("Error encoding data: \(error.localizedDescription)")
        }
    }
    
    static func getRequestsFirebase(completion: @escaping ([RequestModel]?) -> Void) {
        
    }
}



struct RequestModel: Codable {
    var field1: String
    var field2: String
    var field3: String
    var field4: String
    var field5: String
    var number: Int
    var field6: String
}
