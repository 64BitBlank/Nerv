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
    
    private var db = Firestore.firestore()
    
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
            try await db.collection("requests").addDocument(data: json)
        } catch {
            print("Error encoding data: \(error.localizedDescription)")
        }
    }
    
    
    func fetchRequests() async {
        do {
            let querySnapshot = try await db.collection("requests").getDocuments()
            self.requests = querySnapshot.documents.map { $0 }
        } catch {
            print("Error fetching documents: \(error.localizedDescription)")
        }
    }
    
    
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

    func printNotifications() {
        for notification in notifications {
            print("ID: \(notification.id), Forename: \(notification.Forename), Lastname: \(notification.Lastname), Additional: \(notification.Additional), StaffNumber: \(notification.StaffNumber), Summary: \(notification.Summary), Alt Name: \(notification.altName), Number: \(notification.number)")
        }
    }
    
    
}

