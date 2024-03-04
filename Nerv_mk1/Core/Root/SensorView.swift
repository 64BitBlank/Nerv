//
//  SensorView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 25/02/2024.
//

import SwiftUI

struct SensorView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @ObservedObject var dataViewModel = DataViewModel()

    var body: some View {
        List(dataViewModel.sensors) { sensor in
            Section("Sensor Device 1"){
                VStack(alignment: .leading) {
                    Text("Counter: \(sensor.Counter)")
                    Text("LDR: \(sensor.LDR)")
                    Text("Voltage: \(sensor.Voltage) V")
                }
            }

        }
        .onAppear {
            Task{
                dataViewModel.fetchData(uid: viewModel.currentUser!.id)
            }
        }
    }
}

#Preview {
    SensorView()
}
