//
//  User.swift
//  Nerv_mk1
//
//  Created by James Hallett on 01/11/2023.
//

import Foundation

// User Object
// Adding Codable allows for mapping of json data into swift object - Decoding from the DB
struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    
    // Get initials
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
}
extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString, fullname: "James Hallett", email: "jameshallett@gmail.com")
}
