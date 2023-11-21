//
//  RequestView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 11/11/2023.
//

import SwiftUI

import Firebase
import FirebaseFirestore


struct RequestView: View {
    @State private var searchText: String = ""
    @State private var field1: String = ""
    @State private var field2: String = ""
    @State private var field3: String = ""
    @State private var field4: String = ""
    @State private var field5: String = ""
    @State private var field6: String = ""
    
    @State private var number: Int = 1
    @State private var staffNumber: String = ""

    @EnvironmentObject var viewModel2: AuthViewModel
    @EnvironmentObject var requestAuthModel: RequestAuthModel
    
    var isButtonEnabled: Bool {
        return !field1.isEmpty && !field2.isEmpty && !field3.isEmpty
    }
   

    var body: some View {
        if let user = viewModel2.currentUser {
            VStack {
                
                SearchBar(text: $searchText)
                Form {
                    Section(header: Text("Staff ID")){
                        // Replace with automation of user pulled information
                        TextField("Staff Number*", text: $staffNumber)
                    }
                    .onAppear {
                        // Assign the value to staffNumber when the view appears
                        staffNumber = user.id
                    }
                    Section(header: Text("Patient Details")) {
                        TextField("Fore Name*", text: $field1)
                        TextField("Family Name*", text: $field2)
                        TextField("Alternate Name", text: $field3)
                        // Add more TextField for additional fields as needed
                    }
                    Section(header: Text("Urgency")){
                        HStack {
                            Picker("Rating [1-9]*", selection: $number) {
                                ForEach(1...9, id: \.self) { number in
                                    Text("\(number)")
                                }
                            }
                        }
                    }
                    Section(header: Text("Description")) {
                        HStack {
                            Text("Brief summary of condition*")
                                .font(.caption)
                                .foregroundColor(.gray)
                            // Character count
                            Text("[\(field5.count)]")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.leading, 30)
                        }
                        // Use TextEditor for multi-line input
                        TextEditor(text: $field5)
                            .frame(height: CGFloat(30 * 4)) // Set the initial height based on the number of lines
                            .lineSpacing(5) // Optional: Add line spacing
                    }
                    Section(header: Text("Additional Requests")){
                        HStack{
                            TextField("Additionals", text: $field6)
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                
                Button{
                    Task {
                        do {
                            try await requestAuthModel.uploadToFirebase(
                                field1: field1,
                                field2: field2,
                                field3: field3,
                                field4: staffNumber,
                                field5: field5,
                                number: number,
                                field6: field6
                            )
                        } catch {
                            print("Error uploading to Firebase: \(error.localizedDescription)")
                        }
                    }
                    // Move user out of requests page
                    
                }label: {
                    HStack{
                        Text("Send Request")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 62, height: 48)
                }
                .background(Color(.systemBlue))
                .cornerRadius(10.0)
                .padding()
                .disabled(!isButtonEnabled) // Disable the button if any field is empty
                .opacity(isButtonEnabled ? 1.0 : 0.5)
                .cornerRadius(10.0)
            }
        }
//        .navigationTitle("Request Page")
    }
}

struct SearchBar: View {
    @Binding var text: String
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 20)
            Image(systemName: "magnifyingglass")
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
            
        }
        .padding(.top, 10)
        
    }
}

#Preview {
    RequestView()
}
