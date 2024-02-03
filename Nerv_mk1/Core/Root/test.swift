//
//  test.swift
//  Nerv_mk1
//
//  Created by James Hallett on 26/01/2024.
//

import SwiftUI

struct test: View {
    @State private var selectedWard = ""
    @State private var showMenu: Bool = false
    @State private var isEditing: Bool = false
    @State private var showingSaveAlert = false
    @State private var attemptToSaveEdits = false
    @State private var showImageOverlay = false
    @State private var selectedImageUrl: URL?
    @State private var selectedImageTitle: String = ""
    @State private var notes: String = ""
    
    @EnvironmentObject var viewModel: AuthViewModel
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
                                Group{
                                    Text("Request ID: \(request.id)")
                                    Text("Ward: \(request.ward)")
                                    Text("Additional: \(request.Additional)")
                                    Text("Current Perscription: \(request.CurrentPerscription)")
                                    Text("Forename: \(request.Forename)")
                                    Text("Lastname: \(request.Lastname)")
                                    Text("MedicalHistory: \(request.MedicalHistory)")
                                    Text("PersonalContact: \(request.PersonalContact)")
                                    Text("Sex: \(request.Sex)")
                                    //Text("StaffNumber: \(request.StaffNumber)")
                                    Text("Date-Of-Birth: \(request.dob)")
                                }
         
                                Group{
                                    Divider()
                                    if isEditing {
                                        Section(header: Text("Editing Notes:")) {
                                            HStack {
                                                Text("Additional notes")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                // Character count
                                                Text("[\(notes.count)]")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                    .padding(.leading, 30)
                                            }
                                            TextEditor(text: $notes)
                                                .frame(height: CGFloat(30 * 4))
                                                .lineSpacing(5)
                                        }
                                    } else {
                                        HStack {
                                            Text("Notes: ")
                                                .fontWeight(.bold)
                                            Text("\(request.notes)")
                                        }
                                    }
                                    Divider()
                                }
                                
                                Group{
                                    Button(action: {
                                        if isEditing {
                                            // User is trying to finish editing
                                            attemptToSaveEdits = true
                                            // Alert user action has occured
                                            showingSaveAlert = true
                                        }
                                        isEditing.toggle()
                                    }) {
                                        Text(isEditing ? "Done" : "Edit Notes")
                                    }
                                    
                                    .alert(isPresented: $showingSaveAlert) {
                                        Alert(
                                            title: Text("Confirm Changes"),
                                            message: Text("Are you sure you want to save these changes?"),
                                            primaryButton: .destructive(Text("Save")) {
                                                if attemptToSaveEdits {
                                                    viewModel_request.addNotesToPatient(patientID: request.id, notes: notes)
                                                    viewModel_request.fetchPatientDetails(patientID: request.id)
                                                    isEditing = false
                                                    attemptToSaveEdits = false
                                                }
                                            },
                                            secondaryButton: .cancel {
                                                isEditing = false
                                                attemptToSaveEdits = false
                                            }
                                        )
                                    }
                                }
                                .onChange(of: notes) { newPatientRef in
                                    viewModel_request.fetchPatientDetails(patientID: request.id)
                                }
                                
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

struct ImageView2: View {
    @StateObject private var loader = ImageLoader()
    let urlString: String
    @Binding var selectedImageUrl: URL?
    @Binding var showImageOverlay: Bool
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .blur(radius: 7)
                    .onTapGesture {
                        self.selectedImageUrl = URL(string: urlString)
                        self.showImageOverlay = true
                    }
            } else {
                ProgressView()
                    .onAppear {
                        loader.loadImage(fromURL: urlString)
                    }
            }
        }
    }
}
struct ImageOverlayView2: View {
    let imageUrl: URL
    let title: String

    var body: some View {
        VStack {
            Text(title)
                .font(.title)
                .padding()

            AsyncImage(url: imageUrl) { image in
                image.resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(maxWidth: .infinity, maxHeight: .infinity)
            } placeholder: {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.6))
    }
}

#Preview {
    test()
}
