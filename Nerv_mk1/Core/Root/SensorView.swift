//
//  SensorView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 25/02/2024.
//

import SwiftUI

struct SensorView: View {
    @ObservedObject var dataViewModel = DataViewModel()
    var body: some View {
        List(dataViewModel.sensors) { sensor in
            Section("Heart Rate Sensor"){
                VStack(alignment: .leading) {
                    Text("LDR Data: \(sensor.ldrData)")
                    Text("Voltage: \(sensor.voltage) V")
                }
            }

        }
        .onAppear {
            dataViewModel.fetchData()
        }
    }
}

#Preview {
    SensorView()
}
