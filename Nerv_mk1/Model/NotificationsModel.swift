//
//  NotificationsModel.swift
//  Nerv_mk1
//
//  Created by James Hallett on 21/11/2023.
//

import Foundation

struct NotificationsModel: Identifiable, Codable {
    var id: String = UUID().uuidString
    var Additional: String
    var Forename: String
    var Lastname: String
    var StaffNumber: String
    var Summary: String
    var altName: String
    var number: Int

}
