//
//  PatientDetailsView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 03/01/2024.
//

import SwiftUI

struct PatientDetailsView: View {
    var patientData: [String: Any]
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
                        Text("\(patientData["Forename"] as? String ?? "N/A") \(patientData["Lastname"] as? String ?? "N/A")")
                    }
                    HStack {
                        Text("Alternate Name:")
                            .bold()
                        Text("\(patientData["altName"] as? String ?? "N/A")")
                    }
                    HStack {
                        Text("Staff Number:")
                            .bold()
                        Text("\(patientData["StaffNumber"] as? String ?? "N/A")")
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
                        Text("\(patientData["Summary"] as? String ?? "N/A")")
                    }
                    HStack {
                        Text("Additional Notes:")
                            .bold()
                        Text("\(patientData["Additional"] as? String ?? "N/A")")
                    }
                    HStack {
                        Text("Medical Rating:")
                            .bold()
                        Text("\(patientData["number"] as? Int ?? 0)")
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("Patient Details", displayMode: .inline)
    }
}

struct PatientDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PatientDetailsView(patientData: [
            "Forename": "John",
            "Lastname": "Smith",
            "StaffNumber": "DuzDbTkYRhZeEAryKupHHZqD6xB3",
            "Summary": "Severe abdominal pain",
            "Additional": "Immediate surgery required",
            "altName": "Jo",
            "number": 8
        ])
    }
}
