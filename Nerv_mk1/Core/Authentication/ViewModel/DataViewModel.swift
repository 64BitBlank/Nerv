//
//  DataViewModel.swift
//  Nerv_mk1
//
//  Created by James Hallett on 25/02/2024.
//

import Foundation
import Firebase
import Combine

class DataViewModel: ObservableObject {
    @Published var sensors = [Sensor]()

    private var dbRef: DatabaseReference = Database.database().reference()

    func fetchData() {
        dbRef.child("Sensors").observe(.value) { snapshot in
            var newSensors = [Sensor]()

            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let value = snapshot.value as? [String: Any],
                   let ldrData = value["ldr_data"] as? Int,
                   let voltage = value["voltage"] as? Float {
                    let id = snapshot.key
                    newSensors.append(Sensor(id: id, ldrData: ldrData, voltage: voltage))
                }
            }

            DispatchQueue.main.async {
                self.sensors = newSensors
            }
        }
    }
}
struct Sensor: Identifiable {
    let id: String
    let ldrData: Int
    let voltage: Float
}
