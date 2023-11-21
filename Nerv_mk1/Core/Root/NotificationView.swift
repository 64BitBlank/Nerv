//
//  NotificationView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 11/11/2023.
//

import SwiftUI
import Firebase

struct NotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

struct NotificationView: View {
    @State private var notifications:
    // Tester notificatons
    [NotificationItem] = [
        NotificationItem(title: "New Message", message: "You have a new message."),
        NotificationItem(title: "Reminder", message: "Don't forget to complete your tasks."),
        // Add more notifications as needed
    ]
    var body: some View {
        NavigationView {
            List(notifications) { notification in
                NavigationLink(destination: Text(notification.message)) {
                    VStack(alignment: .leading) {
                        Text(notification.title)
                            .font(.headline)
                        Text(notification.message)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarItems(trailing:
                Button(action: {
                    // Implement clear all notifications logic
                    notifications.removeAll()
                }) {
                    Text("Clear All")
                        .foregroundColor(.red)
                }
            )
        }
    }
}


#Preview {
    NotificationView()
}
