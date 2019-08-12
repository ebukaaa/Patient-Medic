//
//  Appointment.swift
//  Patient Medic
//
//  Created by ebuks on 14/06/2019.
//  Copyright © 2019 ebukaa. All rights reserved.
//

import Foundation
import RealmSwift

class Appointment: Object {
    
    //    MARK:- Object properties
    @objc dynamic var patientEmail = String()
    
    @objc dynamic var medicalDetails = String()
    @objc dynamic var medicalDetail: MedicalDetail?
    
    @objc dynamic var location = String()
    @objc dynamic var time = Date()
    @objc dynamic var contactInfo = String()
    
    //    TODO:- linking
    var linkToPatient = LinkingObjects(fromType: Patient.self, property: "appointments")
    
    //    MARK:- Class properties
    static var dueDateFormat: DateFormatter {
        
        let format = DateFormatter()
        
        format.dateStyle = .short
        format.timeStyle = .short
        
        return format
    }
    static let locations = ["Pick a location", "New Orleans", "Valencia", "Lagos"]
}

// MARK:- Class methods
extension Appointment {
    static func dateAndCalendar() -> (Calendar, DateComponents) {
        
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        
        dateComponents.calendar = calendar
        
        return (calendar, dateComponents)
    }
    static func deleteOld(_ appointments:Results<Appointment>) {
        
        var (calendar, dateComponents) = Appointment.dateAndCalendar()
        
        dateComponents.hour = 1
        
        let time = calendar.date(byAdding: dateComponents, to: Date())
        
        for appointment in appointments {
            
            print("\n appointment time: ", appointment.time, " & current time: ", Date(), "\n")
            
            let appointmentTime = calendar.date(byAdding: dateComponents, to: appointment.time)
            
            if  appointmentTime! < time! {
                print("\n appointment time: ", appointmentTime!, " & current time: ", time!, "\n")
                
                do {
                    try realmFile.write {
                        realmFile.delete(appointment)
                    }
                } catch {
                    print("\n Error deleting appointments from realm file: \n", error, "\n")
                }
            }
        }
    }
    static func maximumTime() -> Date {
        
        var (calendar, dateComponents) = Appointment.dateAndCalendar()
        
        dateComponents.day = 7
        
        guard
            let maximumTime = calendar.date(byAdding: dateComponents, to: Date())
            else {
                //            TODO: 7 days ahead
                return Date().addingTimeInterval(24*7*60*60)
        }
        return maximumTime
    }
    static func minimumTime() -> Date {
        
        var (calendar, dateComponents) = Appointment.dateAndCalendar()
        
        dateComponents.minute = 45
        
        guard
            let minimumTime = calendar.date(byAdding: dateComponents, to: Date())
            else {
                //            TODO: 45 minutes ahead
                return Date().addingTimeInterval(45*60)
        }
        return minimumTime
    }
    static func link(to patient:Patient, with appointments:Results<Appointment>) {
        
        if patient.appointments.isEmpty {
            do {
                try realmFile.write {
                    
                    for appointment in appointments {
                        
                        patient.appointments.append(appointment)
                    }
                }
            } catch {
                print("\n Error writing to realm file: ", error, "\n")
            }
        }
    }
}
