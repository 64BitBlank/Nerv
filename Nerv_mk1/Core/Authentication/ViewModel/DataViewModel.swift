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
            guard let value = snapshot.value as? [String: AnyObject] else {
                print("Error: Snapshot is not a dictionary")
                return
            }
            
            let id = value["id"] as? String ?? ""
            let ldrData = value["ldr_data"] as? Int ?? 0
            let voltage = value["voltage"] as? String ?? ""
            
            let sensor = Sensor(id: id, ldrData: ldrData, voltage: voltage)
            DispatchQueue.main.async {
                self.sensors = [sensor]
                print("Data updated: \(self.sensors)")
            }
        }
    }

}
struct Sensor: Identifiable {
    let id: String
    let ldrData: Int
    let voltage: String
}
