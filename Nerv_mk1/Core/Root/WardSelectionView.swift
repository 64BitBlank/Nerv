//
//  WardSelectionView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 24/01/2024.
//

import SwiftUI

struct WardSelectionView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    @State var isEditing = false
    @State var selection = Set<String>()
    @State var finalSelections = [String]() // Array to hold final selections
    
    let wards = ["Cardiology", "Oncology", "Pediatrics", "Neurology", "Emergency", "Orthopedics", "Maternity"]

    var body: some View {
        NavigationView {
            VStack {
                
                List(wards, id: \.self, selection: $selection) { name in
                    Text(name)
                }
                .navigationBarTitle("Ward Selection")
                .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))
                .animation(Animation.spring())

                Button(action: {
                    if self.isEditing {
                        // "Done" button pressed, update the final selections array
                        self.finalSelections = Array(self.selection)
                        self.viewModel.updateUserWards(wards: self.finalSelections)

                    }
                    self.isEditing.toggle()
                }) {
                    Text(isEditing ? "Done" : "Edit")
                        .frame(width: 80, height: 50)
                }

                if isEditing {
                    Section() {
                        ForEach(Array(selection), id: \.self) { selectedWard in
                            Text(selectedWard)
                        }
                    }
                } else {
                    Section() {
                        ForEach(finalSelections, id: \.self) { finalSelection in
                            if isEditing == false && finalSelections.count > 1 {
                                Text(finalSelection)
                            }
                        }
                    }
                }
            }
            .padding(.bottom)
        }
    }
}


#Preview {
    WardSelectionView()
}
