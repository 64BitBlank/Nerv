//
//  NotificationsModel.swift
//  Nerv_mk1
//
//  Created by James Hallett on 21/11/2023.
//

import Foundation

struct NotificationsModel: Identifiable, Hashable {
    var id = UUID()
    var forename: String
    var lastname: String
    var altName: String
    var staffNumber: String
    var summary: String
    var number: Int
    var additional: String
}
