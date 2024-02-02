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
    @EnvironmentObject var viewModel_user: AuthViewModel

    var body: some View {
            NavigationView {
                List(viewModel.requests, id: \.documentID) { document in
                    if let data = document.data(), let num = data["number"] as? Int {
                        NavigationLink(destination: PatientDetailsView(patientData: data)) {
                            VStack(alignment: .leading) {
                                Text("Patient ID: \(document.documentID)")
                                    .font(.headline)
                                Text("Rating: \(num)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                print("Delete action")
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                print("Other action")
                                if let user = viewModel_user.currentUser{
                                    viewModel.addUserReference(documentID: document.documentID, userID: user.id)
                                }
                                // Implement action here to assign user the patient & add to logs
                            } label: {
                                Label("Other", systemImage: "ellipsis.circle")
                            }
                            .tint(.blue)
                        }
                    } else {
                        Text("Document \(document.documentID) does not have a forename.")
                    }
                }
                .onAppear(){
                    Task{
                        await viewModel_user.fetchWards()
                    }
                }
                .navigationTitle("Requests")
                .navigationBarItems(trailing:
                    Button(action: {
                    Task {
                        //debugging wards for user not appearing -- fixed
                        print(viewModel_user.wards)
                        await viewModel.fetchRequests(wards: viewModel_user.wards)
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
