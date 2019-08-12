//
//  Symptom.swift
//  Patient Medic
//
//  Created by ebuks on 05/07/2019.
//  Copyright © 2019 ebukaa. All rights reserved.
//

import Foundation
import RealmSwift

class Symptom: Object {
    
    //    MARK:- Objects properties
    @objc dynamic var patientEmail = String()
    @objc dynamic var name = String()
    @objc dynamic var id = Int()
    @objc dynamic var isPicked = Bool()
    
    //    TODO:- linking
    var linkToMedicalDetail = LinkingObjects(fromType: MedicalDetail.self, property: "symptoms")
    
    //    MARK:- Class properties
    static var url = String()
    static var dictionary = [String:Int]()
    static var names: [String] {
        
        var locationNames = [String]()
        
        locationNames = MedicalDetail.getLocationNames(dictionary, &locationNames)
        
        return locationNames
    }
    static var ids: [Int] {
        var symptoms = [Int]()
        
        for id in dictionary.values {
            symptoms.append(id)
        }
        return symptoms
    }
}

// MARK:- Class methods
extension Symptom {
    static func link(to appointment:Appointment, with symptoms:Results<Symptom>) {
        
        guard
            let patientSymptoms = appointment.medicalDetail?.symptoms
            else {
                return
        }
        
        if patientSymptoms.isEmpty {
            do {
                try realmFile.write {
                    
                    for symptom in symptoms {
                        
                        appointment.medicalDetail?.symptoms.append(symptom)
                    }
                }
            } catch {
                print("\n Error writing to realm file: ", error, "\n")
            }
        }
    }
}
