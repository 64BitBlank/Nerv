//
//  WardSelectionView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 24/01/2024.
//

import SwiftUI

struct WardSelectionView: View {
    @Environment(\.editMode) var mode
    @State private var selection = Set<String>()
    @State private var selectedWards = [String]()
    @State private var isEditing: Bool = false

    let wards = ["Cardiology", "Oncology", "Pediatrics", "Neurology", "Emergency", "Orthopedics", "Maternity"]

    var body: some View {
        NavigationView {
            List(wards, id: \.self, selection: $selection) { name in
                Text(name)
            }
            .navigationTitle("Ward Selection")
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                    // remove what was previously inside the array
                        .onAppear(){
                            // ensure list it cleared
                            selectedWards.removeAll()
                        }
                        .onChange(of: selection) { newSelection in
                            
                            // Add selected items to the separate array
                            selectedWards = Array(newSelection)
                            // Optionally, you can print or perform other actions with the selected items here
                            print("Current Selected Wards: \(selectedWards)")
                        }
                    
                }
            }
        }
        Section(header: Text("Selected Wards:")) {
            if selectedWards.isEmpty {
                Text("None selected")
                    .foregroundColor(.gray)
            } else {
                ForEach(selectedWards, id: \.self) { ward in
                    Text(ward)
                }
            }
        }
    }
}

#Preview {
    WardSelectionView()
}
