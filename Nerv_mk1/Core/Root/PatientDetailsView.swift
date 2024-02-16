//
//  PatientDetailsView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 03/01/2024.
//

import SwiftUI
import FirebaseFirestore


struct PatientDetailsView: View {
    //var patientData: [String: Any]
    @ObservedObject var patientData: Request
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
                        Text("Staff Number:")
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
                    HStack {
                        Text("Ward:")
                            .bold()
                        Text(patientData.ward)
                    }
                }
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
