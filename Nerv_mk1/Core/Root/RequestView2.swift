//
//  RequestView2.swift
//  Nerv_mk1
//
//  Created by James Hallett on 21/11/2023.
//

import SwiftUI

struct RequestView2: View {
    @State var isEditing = false
    @State var selection = Set<String>()
    @State var finalSelections = [String]() // New array to hold final selections

    let wards = ["Cardiology", "Oncology", "Pediatrics", "Neurology", "Emergency", "Orthopedics", "Maternity"]

    var body: some View {
        NavigationView {
            VStack {
                List(wards, id: \.self, selection: $selection) { name in
                    Text(name)
                }
                .navigationBarTitle("Wards")
                .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))
                .animation(Animation.spring())

                Button(action: {
                    if self.isEditing {
                        // "Done" button pressed, update the final selections array
                        self.finalSelections = Array(self.selection)
                    }
                    self.isEditing.toggle()
                }) {
                    Text(isEditing ? "Done" : "Edit")
                        .frame(width: 80, height: 40)
                }

                if isEditing {
                    Section(header: Text("Selected Wards:")) {
                        ForEach(Array(selection), id: \.self) { selectedWard in
                            Text(selectedWard)
                        }
                    }
                } else {
                    Section() {
                        ForEach(finalSelections, id: \.self) { finalSelection in
                            Text(finalSelection)
                        }
                    }
                }
            }
            .padding(.bottom)
        }
    }
}


#Preview {
    RequestView2()
}
