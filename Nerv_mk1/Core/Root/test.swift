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
                    print(viewModel_request.requestDetails)
                }
            // Filter and display requests for the selected ward
            let filteredRequests = viewModel_request.requestDetails.filter { $0.ward == selectedWard }
            if !filteredRequests.isEmpty {
                ForEach(filteredRequests) { request in
                    Text("\(request.id) - Active in \(request.ward)")
                        .foregroundColor(.gray)
                }
            } else {
                Text("No patient references found for \(selectedWard).")
            }
            Carousel(items: 5) { item in
                RoundedRectangle(cornerRadius: 15)
                    .fill(.gray)
                    .opacity(0.5)
                    .shadow(radius: 10.0)
                    .padding()
                    .overlay(Text(String(item)).font(.title).foregroundColor(.white))
                    .carouselItem()
            }
            .padding(.top)
        }
        .onAppear(){
            Task{
                authViewModel.fetchWards()
                // Assume fetchPatientRefs() updates a patientRefs property in authViewModel
                await authViewModel.fetchPatientRefs()
                // After brief delay to ensure patientRefs are fetched, fetch request details
                //print(authViewModel.patientRefs)
                await viewModel_request.fetchPatientWard(ids: authViewModel.patientRefs)
                print(viewModel_request.requestDetails)
            }

        }
        
    }
}



#Preview {
    test()
}
