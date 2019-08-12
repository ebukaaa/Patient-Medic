//
//  Patient.swift
//  Patient Medic
//
//  Created by ebuks on 13/06/2019.
//  Copyright © 2019 ebukaa. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

enum GenderType:String {
    
    case male = "Male"
    case female = "Female"
}

class Patient: Object {
    
    //    MARK:- Object properties
    @objc dynamic var id = Int()
    @objc dynamic var firstName = String()
    @objc dynamic var lastName = String()
    @objc dynamic var address = String()
    @objc dynamic var email = String()
    @objc dynamic var phoneNumber = String()
    
    var appointments = List<Appointment>()
    
    var password = String()
    
    var contactInfo: [String] {
        
        var contactInfo = ["Pick a contact information"]
        
        if !address.isEmpty {
            contactInfo.append(address)
            
        }; if !phoneNumber.isEmpty {
            contactInfo.append(phoneNumber)
            
        }; if !email.isEmpty {
            contactInfo.append(email)
        }
        return contactInfo
    }
    
    //    MARK:- Class properties
    static var age = Int()
    static var gender = GenderType.RawValue()
    
    //    MARK: overrides
    override static func primaryKey() -> String? {

        return "id"
    }
}

// MARK:- Class methods
extension Patient {
    static func alertControl() -> UIAlertController {
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        
        alert.addAction(okay)
        
        return alert
    }
    static func invalidPassword() -> UIAlertController {
        
        let alert = alertControl()
        alert.title = "Password must be 6 characters long or more"
        
        return alert
    }
    static func invalidEmail() -> (UIAlertController, NSPredicate) {
        
        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailReg)
        
        let alert = alertControl()
        alert.title = "Email is badly formatted"
        
        return (alert, emailTest)
    }
    static func usedEmail() -> UIAlertController {
        
        let alert = alertControl()
        alert.title = "Email is already used"
        
        return alert
    }
}
