//
//  PatientDetailsView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 03/01/2024.
//

import SwiftUI
import FirebaseFirestore


struct PatientDetailsView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var requestModel: RequestAuthModel

    @ObservedObject var patientData: Request
    
    @State private var showMenu: Bool = false
    @State private var showImageOverlay = false
    @State private var selectedImageUrl: URL?
    @State private var selectedImageTitle: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Text("Patient Information")
                        .font(.title)
                        .bold()
                    Divider()
                    HStack {
                        Text("Name:")
                            .bold()
                        Text(patientData.Forename + " " + patientData.Lastname)
                    }
                    HStack {
                        Text("Alternate Name:")
                            .bold()
                        Text(patientData.altName)
                    }
                    HStack {
                        Text("Sex:")
                            .bold()
                        Text(patientData.Sex)
                    }
                    HStack {
                        Text("Date of Birth:")
                            .fontWeight(.bold)
                        // Use the dateValue() method to convert Timestamp to Date
                        let dobDate = patientData.dob.dateValue()
                        let formattedDOB = DateFormatter.dobOutputFormatter.string(from: dobDate)
                        Text(" \(formattedDOB)")
                    }
                    HStack {
                        Text("Contact Number:")
                            .fontWeight(.bold)
                        Text(patientData.PersonalContact)
                    }
                    HStack {
                        Text("Previous Staff ID:")
                            .bold()
                        Text(patientData.StaffNumber)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }

                Group {
                    Text("Medical Information")
                        .font(.title2)
                        .bold()
                        .padding(.top, 40)
                    Divider()
                    HStack {
                        Text("Summary:")
                            .bold()
                        Text(patientData.Summary)
                    }
                    HStack {
                        Text("Additional Notes:")
                            .bold()
                        Text(patientData.Additional)
                    }
                    HStack {
                        Text("Medical Rating:")
                            .bold()
                        Text("\(patientData.number)")
                    }
                    HStack{
                        Text("N.E.W.S Score:")
                            .bold()
                        Text("\(patientData.newsScore)")
                    }
                    HStack{
                        Text("Medical History:")
                            .bold()
                        Text("\(patientData.MedicalHistory)")
                    }
                    HStack {
                        Text("Previous Ward:")
                            .bold()
                        Text(patientData.ward)
                    }
                    HStack{
                        Text("Previous Notes:")
                            .bold()
                        Text("\(patientData.notes)")
                    }
                }
                Group {
                    Text("Image Refrences")
                        .font(.title2)
                        .bold()
                        .padding(.top, 40)
                    Divider()
                    
                    if !patientData.PhotoRefs.isEmpty {
                        let photoRefs = patientData.PhotoRefs
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
                    print("Selected Image URL: \(url)")
                }
            }
            .onAppear(){
                print(patientData.PhotoRefs)
            }
            .padding()
        }
        .navigationBarTitle("Patient Details", displayMode: .inline)
    }
}

#Preview{
    PatientDetailsView(patientData: (Request.init(
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
    ))
}
