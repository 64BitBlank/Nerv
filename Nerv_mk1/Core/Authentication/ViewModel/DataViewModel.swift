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

    func fetchData(uid: String) {
        dbRef.child("UserSensors").child(uid).observe(.value, with: { snapshot in
            if let value = snapshot.value as? [String: Any] {
                let counter = value["Counter"] as? Int ?? 0
                let ldr = value["LDR"] as? Int ?? 0
                let voltage = value["Voltage"] as? Double ?? 0.0
                
                let sensor = Sensor(id: snapshot.key, Counter: counter, LDR: ldr, Voltage: voltage)
                DispatchQueue.main.async {
                    self.sensors = [sensor]
                    print("Data updated: \(self.sensors)")
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
    

struct Sensor: Identifiable {
    let id: String
    let Counter: Int
    let LDR: Int
    let Voltage: Double
}
