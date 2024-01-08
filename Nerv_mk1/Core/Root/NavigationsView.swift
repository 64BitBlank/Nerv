//
//  NavigationView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 07/11/2023.
////  NavigationView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 07/11/2023.
//

import SwiftUI
// Getting timestamp for date-of-birth formatting
import Firebase

struct NavigationsView: View {
    @State private var showMenu: Bool = false
    @State private var isEditing: Bool = false
    @State private var showingSaveAlert = false
    @State private var attemptToSaveEdits = false
    
    @State private var notes: String = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject private var viewModel_request = RequestAuthModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main body for active tasks
                if let patientRef = viewModel.patientRef {
                    VStack {
                        // Top of page
                        HStack {
                            Text("Home Page")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.top, 20)
                                
                        }
                        .padding()
                        
                        Divider()
                            .padding(.horizontal, 50)
                        if (patientRef.isEmpty){
                            Text("No Active Cases")
                        }else{
                            Text(patientRef + " - Active")
                                .foregroundColor(.gray)
                                .padding()
                        }
                        
                        Divider()
                        
                        // Middle of page
                        Group{
                            if let patientData = viewModel_request.patientData {
                                VStack(alignment: .leading, spacing: 10) {
                                            Text("Patient Information")
                                                .font(.headline)
                                                .padding(.vertical, 5)

                                            Divider()

                                            HStack {
                                                Text("Name:")
                                                    .fontWeight(.bold)
                                                Text("\(patientData["Forename"] as? String ?? "N/A") \(patientData["Lastname"] as? String ?? "N/A")")
                                            }
                                            HStack {
                                                Text("Alternate Name:")
                                                    .fontWeight(.bold)
                                                Text("\(patientData["altName"] as? String ?? "N/A")")
                                            }

                                            HStack {
                                                Text("Date of Birth:")
                                                    .fontWeight(.bold)
                                                // Extract dob as a Timestamp and convert to Date
                                                if let dobTimestamp = patientData["dob"] as? Timestamp {
                                                    let dobDate = dobTimestamp.dateValue()
                                                    Text(DateFormatter.mediumStyle.string(from: dobDate))
                                                } else {
                                                    Text("N/A")
                                                }
                                            }

                                            HStack {
                                                Text("Sex:")
                                                    .fontWeight(.bold)
                                                Text("\(patientData["Sex"] as? String ?? "N/A")")
                                            }

                                            HStack {
                                                Text("Contact Number:")
                                                    .fontWeight(.bold)
                                                Text("\(patientData["PersonalContact"] as? String ?? "N/A")")
                                            }

                                            HStack {
                                                Text("Ward:")
                                                    .fontWeight(.bold)
                                                Text("\(patientData["Ward"] as? String ?? "N/A")")
                                            }

                                            HStack {
                                                Text("Medical History:")
                                                    .fontWeight(.bold)
                                                Text("\(patientData["MedicalHistory"] as? String ?? "N/A")")
                                            }

                                            HStack {
                                                Text("Current Prescription:")
                                                    .fontWeight(.bold)
                                                Text("\(patientData["CurrentPerscription"] as? String ?? "N/A")")
                                            }

                                            HStack {
                                                Text("Summary:")
                                                    .fontWeight(.bold)
                                                Text("\(patientData["Summary"] as? String ?? "N/A")")
                                            }

                                            HStack {
                                                Text("Additionals:")
                                                    .fontWeight(.bold)
                                                Text("\(patientData["Additional"] as? String ?? "N/A")")
                                            }
                                    
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
                                                    Text(notes)
                                                }
                                                
                                            }
                                        }
                                        .padding(.horizontal)
                            } else {
                                Text("Loading patient data...")
                            }
                        }
                        
                        HStack {
                            Text("")
                        }
                        
                        .padding()
                        
                        Spacer()
                        Spacer()
                        
                        
                        // Bottom of page
                        Divider()
                            .padding(.horizontal, 50)
                        
                        HStack {
                            Spacer()
                            
                            NavigationLink(destination: CameraView()) {
                                Image(systemName: "camera")
                                        .foregroundColor(.blue)
                            }
                            
                            Text("Bottom")
                                .font(.title3)
                                .fontWeight(.medium)
                            
                            Button(action: {
                                if isEditing {
                                    // User is trying to finish editing
                                    attemptToSaveEdits = true
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
                                            // submit notes to firebase here
                                            viewModel_request.addNotesToPatient(patientID: patientRef, notes: notes)
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

                        
                            Spacer()
                        }
                        .padding()
                    }
                    .onAppear {
                        // Fetch patient data when the patientRef is available
                        if !patientRef.isEmpty {
                            viewModel_request.fetchPatientDetails(patientID: patientRef)
                        }
                    }
                    // updates the patient data inline with the new patientRef
                    .onChange(of: patientRef) { newPatientRef in
                        if !newPatientRef.isEmpty {
                            viewModel_request.fetchPatientDetails(patientID: newPatientRef)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .blur(radius: showMenu ? 2 : 0) // Apply blur effect when showMenu is true
                    .frame(maxWidth: .infinity)
                    .background(Color(.white)) // Background color for the content
                    
                }
                GeometryReader { geometry in
                    HStack {
                        SideMenuView()
                            .offset(x: showMenu ? 0 : -geometry.size.width * 0.7)
                            .animation(.easeInOut(duration: 0.3), value: showMenu)
                    }
                }
                
                .background(Color.black.opacity(showMenu ? 0.7 : 0))
                .animation(.easeInOut(duration: 0.3), value: showMenu)
                
                // Top navigation bar with button (positioned in the top-left corner)
                GeometryReader { geometry in
                    VStack {
                        HStack {
                            Button(action: {
                                // When the button is pressed, toggle the showMenu state
                                self.showMenu.toggle()
                            }) {
                                // Change icon based on the showMenu state
                                if showMenu {
                                    Image(systemName: "xmark")
                                        .font(.title)
                                        .foregroundColor(.black)
                                        .offset(x: 10)
                                } else {
                                    Image(systemName: "text.justify")
                                        .font(.title)
                                        .foregroundColor(.black)
                                        .offset(x: 10)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding()
                    }
                }
            }
            .onAppear {
                viewModel.fetchPatientRef()

            }
        }
    }
}

extension DateFormatter {
    static let mediumStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}


#Preview {
    NavigationsView()
}
