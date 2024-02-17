//
//  DismissalNotificationView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 15/02/2024.
//

import SwiftUI

struct DismissalNotificationView: View {
    
    @EnvironmentObject var viewModel_request: RequestAuthModel
    @EnvironmentObject var viewModel_user: AuthViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel_request.dismissalNotifications) { request in
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
                        // add action for dimissing the user...
                    } label: {
                        Label("Other", systemImage: "ellipsis.circle")
                    }
                    .tint(.blue)
                }
            }
            .onAppear() {
                Task {
                    await viewModel_request.fetchDismissalNotifications()
                }
            }
            .navigationTitle("Dismissal Requests")
            .navigationBarItems(trailing:
                                    Button(action: {
                Task {
                    await viewModel_request.fetchDismissalNotifications()
                }
            }) {
                Text("Refresh")
                    .foregroundColor(.blue)
            })
        }
    }
}


#Preview {
    DismissalNotificationView()
}
