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

struct NavigationsView: View {
    @State private var showMenu: Bool = false
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
                                .foregroundColor(.gray)
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
                        
                        Spacer()
                        
                        // Middle of page
                        if let patientData = viewModel_request.patientData {
                            HStack {
                                Text("Patient Name: \(patientData["Forename"] as? String ?? "N/A")")
                                // Add other patient details
                            }

                            HStack {
                                Text("Patient Details: \(patientData["Lastname"] as? String ?? "N/A")")
                                // Add more information
                            }
                        } else {
                            Text("Loading patient data...")
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
                            Text("Bottom")
                                .font(.title3)
                                .fontWeight(.medium)
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

#Preview {
    NavigationsView()
}
