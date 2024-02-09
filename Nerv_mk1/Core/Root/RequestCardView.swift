//
//  RequestCardView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 08/02/2024.
//

import SwiftUI
import FirebaseFirestore

extension DateFormatter {
    // Parser for the input date format
    static let dobInputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Adjust this based on the actual format of your date string
        return formatter
    }()
    
    // Formatter for the output date format
    static let dobOutputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long // For example, "December 31, 2024"
        formatter.timeStyle = .none
        return formatter
    }()
}

struct RequestCardView: View {
    let request: Request // Assuming `Request` is your model
    @State private var selectedWard = ""
    @State private var showMenu: Bool = false
    @State private var isEditing: Bool = false
    @State private var showingSaveAlert = false
    @State private var attemptToSaveEdits = false
    @State private var showImageOverlay = false
    @State private var selectedImageUrl: URL?
    @State private var selectedImageTitle: String = ""
    @State private var notes: String = ""
    @State private var currentCarouselIndex = 0
    
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject var viewModel_request = RequestAuthModel()
    @StateObject var authViewModel = AuthViewModel() // This seems to be the object fetching and storing wards.
    
    var body: some View {
        
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.gray)
            .opacity(0.5)
            .padding()
            .shadow(radius: 10.0)
            .overlay(
                VStack(alignment: .leading, spacing: 8) { // Align VStack content to the leading edge
                    HStack{
                        Text("Request ID:").fontWeight(.bold)
                        Text(" \(request.id)")
                    }
                    HStack{
                        Text("Ward:").fontWeight(.bold)
                        Text(" \(request.ward)")
                    }
                    HStack{
                        Text("Additional:").fontWeight(.bold)
                        Text(" \(request.Additional)")
                    }
                    HStack{
                        Text("Current Prescription:").fontWeight(.bold)
                        Text(" \(request.CurrentPerscription)")
                    }
                    HStack{
                        Text("Forename:").fontWeight(.bold)
                        Text(" \(request.Forename)")
                    }
                    HStack{
                        Text("Lastname:").fontWeight(.bold)
                        Text(" \(request.Lastname)")
                    }
                    HStack{
                        Text("Medical History:").fontWeight(.bold)
                        Text(" \(request.MedicalHistory)")
                    }
                    HStack{
                        Text("Personal Contact:").fontWeight(.bold)
                        Text(" \(request.PersonalContact)")
                    }
                    HStack{
                        Text("Sex:").fontWeight(.bold)
                        Text(" \(request.Sex)")
                    }
                    HStack {
                        Text("Date of Birth:")
                            .fontWeight(.bold)
                        // Use the dateValue() method to convert Timestamp to Date
                        let dobDate = request.dob.dateValue()
                        let formattedDOB = DateFormatter.dobOutputFormatter.string(from: dobDate)
                        Text(" \(formattedDOB)")
                    }
                    HStack{
                        Text("NHS Number:").fontWeight(.bold)
                        Text(" \(request.nhsNumber)")
                    }
                    HStack{
                        Text("N.E.W.S Score:").fontWeight(.bold)
                        Text(" \(request.newsScore)")
                    }
                    HStack{
                        Text("Score:").fontWeight(.bold)
                        Text(" \(request.number)")
                    }
                    Group {
                        Divider()
                        if isEditing {
                            Section(header: Text("Editing Notes:").frame(maxWidth: .infinity, alignment: .leading)) {
                                HStack {
                                    Text("Additional notes")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("[\(notes.count)]")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.leading, 30)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Divider()
                    }
                    // needs representing in reverse order to show latest first
                    if !request.PhotoRefs.isEmpty {
                        let photoRefs = request.PhotoRefs
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                                ForEach(photoRefs, id: \.self) { urlString in
                                    ImageView(urlString: urlString, selectedImageUrl: $selectedImageUrl, showImageOverlay: $showImageOverlay)
                                        .padding(10)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .frame(maxHeight: .infinity)
                        }
                    } else {
                        Text("No photos available")
                            .fontWeight(.bold)
                    }
                    Spacer()
                    
                    
                    // Bottom of page
                    Divider()
                        .padding(.horizontal, 50)
                    
                    HStack {
                        Spacer()
                        if (request.id.isEmpty){
                            Text(" ")
                                .font(.title3)
                                .fontWeight(.medium)
                        }else{
                            NavigationLink(destination: CameraView(patientRef: request.id)) {
                                Image(systemName: "camera")
                                    .foregroundColor(.blue)
                            }
                            
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
                        Spacer()
                    }
                    Spacer()
                }
                // updates the patient data inline with the new patientRef
                    .onChange(of: request.id) { newPatientRef in
                    if !newPatientRef.isEmpty {
                        viewModel_request.fetchPatientDetails(patientID: newPatientRef)
                    }
                }
                
                .sheet(isPresented: $showImageOverlay) {
                    if let url = selectedImageUrl {
                        ImageOverlayView(imageUrl: url, title: selectedImageTitle)
                    }else {
                        Text("Error: No image selected")
                    }
                }
                .onChange(of: selectedImageUrl) { newUrl in
                    if let url = newUrl {
                        print("New Selected Image URL: \(url)")
                    }
                }

                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .blur(radius: showMenu ? 2 : 0) // Apply blur effect when showMenu is true
                .frame(maxWidth: .infinity)
               
                // Ensure all Text views are aligned to the leading edge
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal) // Add horizontal padding to keep text within the bounds of the card
                .padding(.top, 25)
                .padding()
            )
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


#Preview{
    RequestCardView(request: Request.init(
        id: " ",
        ward: " ",
        Additional: " ",
        CurrentPerscription: " ",
        Forename: " ",
        Lastname: " ",
        MedicalHistory: " ",
        PersonalContact: " ",
        Sex: " ",
        StaffNumber: " ",
        Summary: " ",
        altName: " ",
        dob: Timestamp(date: Date()), // Use Timestamp with the current date
        isActive: true,
        notes: " ",
        number: 0,
        PhotoRefs: [" ", " "],
        newsScore: 0,
        nhsNumber: " "
    )
    )
}
