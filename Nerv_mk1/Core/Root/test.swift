//
//  test.swift
//  Nerv_mk1
//
//  Created by James Hallett on 26/01/2024.
//

import SwiftUI

struct test: View {
    @State private var selectedWard = ""
    
    @StateObject var viewModel_request = RequestAuthModel()
    @StateObject var authViewModel = AuthViewModel() // This seems to be the object fetching and storing wards.
    
    var body: some View {
        VStack{
            // User can select wards from database array updates in realtime
            Picker(selection: $selectedWard, label: Text("Home Page")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 10)) {
                    ForEach(authViewModel.wards, id: \.self) { ward in
                        Text(ward).tag(ward)
                    }
                }
                .onChange(of: selectedWard) { newValue in
                    // When the ward changes do this action...
                    //print(viewModel_request.requestDetails)
                }
            // Filter and display requests for the selected ward
            let filteredRequests = viewModel_request.requestDetails.filter { $0.ward == selectedWard }
            if !filteredRequests.isEmpty {
                Text("Active Requests - \(selectedWard)")
                    .foregroundColor(.gray)
            } else {
                Text("No patient requests for \(selectedWard).")
            }
            // make an item for every currently selected ward request in list
            // adding blank card for wards with no current requests for consistency
            let itemCount = max(filteredRequests.count, 1)
            Carousel(items: itemCount, .default) { index in
                if index < filteredRequests.count {
                    let request = filteredRequests[index]
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray)
                        .opacity(0.5)
                        .padding()
                        .shadow(radius: 10.0)
                        .overlay(
                            VStack {
                                Text("Request ID: \(request.id)")
                                    .font(.title)
                                    .foregroundColor(.white)
                                Text("Ward: \(request.ward)")
                                    .foregroundColor(.white)
                            }
                        )
                        .carouselItem()
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
            .padding(.top)
        }
        .onAppear(){
            Task{
                // default the main selection to first ward in list
                await authViewModel.fetchWards()
                if let firstWard = authViewModel.wards.first {
                    selectedWard = firstWard
                }
                // Assume fetchPatientRefs() updates a patientRefs property in authViewModel
                await authViewModel.fetchPatientRefs()
                // After brief delay to ensure patientRefs are fetched, fetch request details
                //print(authViewModel.patientRefs)
                await viewModel_request.fetchPatientWard(ids: authViewModel.patientRefs)
                //print(viewModel_request.requestDetails)
            }

        }
        
    }
}



#Preview {
    test()
}
