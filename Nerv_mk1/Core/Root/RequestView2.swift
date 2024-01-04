//
//  RequestView2.swift
//  Nerv_mk1
//
//  Created by James Hallett on 21/11/2023.
//

import SwiftUI

struct RequestView2: View {
    @ObservedObject private var viewModel = RequestAuthModel()
        var body: some View {
            NavigationView {
              List(viewModel.notifications) { notification in // (2)
                VStack(alignment: .leading) {
                  Text(notification.Forename)
                    .font(.headline)
                  Text(notification.Lastname)
                    .font(.subheadline)
                }
              }
              .navigationBarTitle("Test")
              .onAppear() { // (3)
                self.viewModel.fetchNotifications()
                  self.viewModel.printNotifications()
              }
            }
          }
        }

#Preview {
    RequestView2()
}
