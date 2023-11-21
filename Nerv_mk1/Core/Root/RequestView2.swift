//
//  RequestView2.swift
//  Nerv_mk1
//
//  Created by James Hallett on 21/11/2023.
//

import SwiftUI

struct RequestView2: View {
    @StateObject private var viewModel = RequestAuthModel()

    var body: some View {
        VStack {
            Button("Fetch Requests") {
                Task {
                    await viewModel.fetchRequests()
                }
            }
            
            // Display or process the fetched requests here
            if !viewModel.requests.isEmpty {
                // Display or process the fetched requests
                List(viewModel.requests, id: \.documentID) { document in
                    // Convert the data dictionary to a string representation
                    let dataString = String(describing: document.data())
                    Text("\(document.documentID): \(dataString)")
                }
            }
        }
        .padding()
    }
}

#Preview {
    RequestView2()
}
