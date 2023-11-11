//
//  RequestView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 11/11/2023.
//

import SwiftUI

struct RequestView: View {
    @State private var searchText: String = ""
    @State private var field1: String = ""
    @State private var field2: String = ""
    @State private var field3: String = ""
    
    var isButtonEnabled: Bool {
        return !field1.isEmpty && !field2.isEmpty && !field3.isEmpty
    }

    var body: some View {
        VStack {
            SearchBar(text: $searchText)
            List {
                Section(header: Text("Patient Details")) {
                    TextField("Field 1", text: $field1)
                    TextField("Field 2", text: $field2)
                    // Add more TextField for additional fields as needed
                }
                Section(header: Text("Staff Details")){
                    TextField("Field 1", text: $field3)
                }
            }
            .listStyle(GroupedListStyle())
            
            //sign in button
            Button{
                    // Send off request to firebase
                    // Navigate user back to landing page (navigationView)
                    
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
        .navigationTitle("Request Page")
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
                .padding(.horizontal, 10)
        }
        .padding(.top, 10)
    }
}

#Preview {
    RequestView()
}
