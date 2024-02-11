//
//  Request.swift
//  Nerv_mk1
//
//  Created by James Hallett on 11/02/2024.
//

import Foundation
import FirebaseFirestore

class Request: ObservableObject, Identifiable {
    @Published var id: String
    @Published var ward: String
    @Published var Additional: String
    @Published var CurrentPerscription: String
    @Published var Forename: String
    @Published var Lastname: String
    @Published var MedicalHistory: String
    @Published var PersonalContact: String
    @Published var Sex: String
    @Published var StaffNumber: String
    @Published var Summary: String
    @Published var altName: String
    @Published var dob: Timestamp
    @Published var isActive: Bool
    @Published var notes: String
    @Published var number: Int
    @Published var PhotoRefs: [String]
    @Published var newsScore: Int
    @Published var nhsNumber: String

    init(id: String, ward: String, Additional: String, CurrentPerscription: String, Forename: String, Lastname: String, MedicalHistory: String, PersonalContact: String, Sex: String, StaffNumber: String, Summary: String, altName: String, dob: Timestamp, isActive: Bool, notes: String, number: Int, PhotoRefs: [String], newsScore: Int, nhsNumber: String) {
        self.id = id
        self.ward = ward
        self.Additional = Additional
        self.CurrentPerscription = CurrentPerscription
        self.Forename = Forename
        self.Lastname = Lastname
        self.MedicalHistory = MedicalHistory
        self.PersonalContact = PersonalContact
        self.Sex = Sex
        self.StaffNumber = StaffNumber
        self.Summary = Summary
        self.altName = altName
        self.dob = dob
        self.isActive = isActive
        self.notes = notes
        self.number = number
        self.PhotoRefs = PhotoRefs
        self.newsScore = newsScore
        self.nhsNumber = nhsNumber
    }
}
