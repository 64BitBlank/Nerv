//
//  test.swift
//  Nerv_mk1
//
//  Created by James Hallett on 26/01/2024.
//

import SwiftUI



struct test: View {
    // @State private var selectedWardLocal = ""
    @State private var showMenu: Bool = false
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject var viewModel_request = RequestAuthModel()
    
    var body: some View {
        VStack {
            Picker(selection: $viewModel.selectedWard, label: Text("Home Page")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 15)) {
                    ForEach(viewModel.wards, id: \.self) { ward in
                        Text(ward).tag(ward)
                    }
            }
            .onChange(of: viewModel.selectedWard) { newValue in
                // Actions when ward changes, if needed
            }
            // Filter and display requests for the selected ward
            let filteredRequests = viewModel_request.requestDetails.filter { $0.ward == viewModel.selectedWard }
            if !filteredRequests.isEmpty {
                Text("Active Requests - \(viewModel.selectedWard)")
                    .foregroundColor(.gray)
            } else {
                Text("No patient requests for \(viewModel.selectedWard).")
            }
            
            let itemCount = max(filteredRequests.count, 1)
            Carousel(items: itemCount, .default) { index in
                if index < filteredRequests.count {
                    let request = filteredRequests[index]
                    // Use RequestCardView to display each request
                    RequestCardView(request: request)
                        .carouselItem(.default) // Apply any necessary modifiers for carousel items
                } else {
                    // Display a blank card when there are no active requests
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray)
                        .opacity(0.5)
                        .padding()
                        .shadow(radius: 10.0)
                        .carouselItem()
                }
            }
        }
        .onAppear(){
            Task{
                // default the main selection to first ward in list
                await viewModel.fetchWards()
                if viewModel.selectedWard.isEmpty, let firstWard = viewModel.wards.first {
                    viewModel.selectedWard = firstWard
                }
                // Assume fetchPatientRefs() updates a patientRefs property in authViewModel
                await viewModel.fetchPatientRefs()
                // After brief delay to ensure patientRefs are fetched, fetch request details
                //print(authViewModel.patientRefs)
                await viewModel_request.fetchPatientWard(ids: viewModel.patientRefs)
                //print(viewModel_request.requestDetails)
            }

        }
        
    }
}


#Preview {
    test()
}
