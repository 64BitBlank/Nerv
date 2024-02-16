//
//  NotificationView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 11/11/2023.
//

import SwiftUI
import Firebase

struct NotificationView: View {
    
    @EnvironmentObject var viewModel_request: RequestAuthModel
    @EnvironmentObject var viewModel_user: AuthViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel_request.requestNotification) { request in
                NavigationLink(destination: PatientDetailsView(patientData: request)) {
                    VStack(alignment: .leading) {
                        Text("Patient ID: \(request.id)")
                            .font(.headline)
                        Text("Rating: \(request.number)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        // Implement delete action here
                        print("Delete action for \(request.id)")
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        // Implement other action here
                        print("Other action for \(request.id)")
                        if let user = viewModel_user.currentUser {
                            viewModel_request.addUserReference(documentID: request.id, userID: user.id)
                            // Update your method to match this use case
                        }
                    } label: {
                        Label("Other", systemImage: "ellipsis.circle")
                    }
                    .tint(.blue)
                }
            }
            .onAppear() {
                Task {
                    await viewModel_user.fetchWards()
                    await viewModel_request.fetchRequests(wards: viewModel_user.wards)
                }
            }
            .navigationTitle("Requests")
            .navigationBarItems(trailing:
                                    Button(action: {
                Task {
                    print(viewModel_user.wards)
                    await viewModel_request.fetchRequests(wards: viewModel_user.wards)
                }
            }) {
                Text("Refresh")
                    .foregroundColor(.blue)
            })
        }
    }
}


#Preview {
    NotificationView()
}
