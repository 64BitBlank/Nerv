//
//  DateFormatter.swift
//  Nerv_mk1
//
//  Created by James Hallett on 16/02/2024.
//

import Foundation
import FirebaseFirestore

extension DateFormatter {
    // Parser for the input date format
    static let dobInputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Adjust this based on the actual format of your date string
        return formatter
    }()
    
    // Formatter for the output date format
    static let dobOutputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long // For example, "December 31, 2024"
        formatter.timeStyle = .none
        return formatter
    }()
}
