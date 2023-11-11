//
//  Requests.swift
//  Nerv_mk1
//
//  Created by James Hallett on 11/11/2023.
//

import Foundation

struct Requests {
    let currentDate: Date
    let currentTime: Date
    let description: String
    
    init(currentDate: Date, currentTime: Date, description: String) {
        self.currentDate = currentDate
        self.currentTime = currentTime
        self.description = description
    }
}
