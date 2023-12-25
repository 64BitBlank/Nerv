//
//  NotificationView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 11/11/2023.
//

import SwiftUI
import Firebase

struct NotificationView: View {
    
    @StateObject private var viewModel = RequestAuthModel()

    var body: some View {
        NavigationView {
            List(viewModel.requests, id: \.documentID) { document in
                if let data = document.data(), let forename = data["Forename"] as? String {
                    NavigationLink(destination: Text("Details for \(forename)")) {
                        VStack(alignment: .leading) {
                            Text("Request ID: \(document.documentID)")
                                .font(.headline)
                            Text("Forename: \(forename)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Text("Document \(document.documentID) does not have a forename.")
                }
            }
            .navigationTitle("Requests")
            .navigationBarItems(trailing:
                Button(action: {
                    // Implement your action here, e.g., refresh the list
                    Task {
                        await viewModel.fetchRequests()
                    }
                }) {
                    Text("Refresh")
                        .foregroundColor(.blue)
                }
            )
        }
    }
}
   

#Preview {
    NotificationView()
}
