//
//  MedicalDetail.swift
//  Patient Medic
//
//  Created by ebuks on 05/07/2019.
//  Copyright © 2019 ebukaa. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import SwiftyJSON

class MedicalDetail: Object {
    
    //    MARK:- Objects properties
    @objc dynamic var gender = Patient.gender
    @objc dynamic var age = Patient.age
    @objc dynamic var diagnosis = String()
    
    var symptoms = List<Symptom>()
    
    var linkToAppointment = LinkingObjects(fromType: Appointment.self, property: "medicalDetail")
    
    //    MARK:- Class properties
    static var diagnoseSelector = 0
    static var bodyAreas = [String:Int]()
    static var bodyAreaNames: [String] {
        
        var locationNames = ["Pick body area"]
        
        locationNames = getLocationNames(bodyAreas, &locationNames)
        
        return locationNames
    }
    static var bodySubAreas = [String:Int]()
    static var bodySubAreaNames: [String] {
        
        var locationNames = ["Pick a sub area"]
        
        locationNames = getLocationNames(bodySubAreas, &locationNames)
        
        return locationNames
    }
    static var genderArray = [
        
        "Pick gender",
        GenderType.male.rawValue,
        GenderType.female.rawValue
    ]
    static var token = String()
    static var bodyAreaURL = String()
    static var bodySubAreaURL = String()
    static var authenticationURL = "https://authservice.priaid.ch/" //"https://sandbox-authservice.priaid.ch/"
    static var healthURL = "https://healthservice.priaid.ch/" //"https://sandbox-healthservice.priaid.ch/"
//     static var username = 
//     static var password = 
    static var language = "en-gb"
}

// MARK:- Class methods
extension MedicalDetail {
    static func checkStatus(_ age:Int, _ gender:String) -> String {
        
        var status = ""
        
        if age >= 12 && gender == "Male" {
            status = "man"
            
        } else if age < 12 && gender == "Male" {
            status = "boy"
        }
            
        else if age >= 12 && gender == "Female" {
            status = "woman"
            
        } else if age < 12 && gender == "Female" {
            status = "girl"
        }
        return status
    }
    static func getLocationNames(_ dictionary:[String:Int], _ array:inout [String]) -> [String] {
        
        for names in dictionary.keys {
            array.append(names)
        }
        return array
    }
    static func getLocationIDs(_ dictionary:[String:Int], _ array:inout [Int]) -> [Int] {
        
        for ids in dictionary.values {
            array.append(ids)
        }
        return array
    }
    static func getID(with bodyLocation:String) -> Int {

        var id = 0
        
        switch diagnoseSelector {
        case 1:
            id = MedicalDetail.bodyAreas[bodyLocation] ?? 0
            print("\n body area id \n")
        
        case 2:
            id = MedicalDetail.bodySubAreas[bodyLocation] ?? 0
            print("\n body sub area id \n")
            
        case 3:
            id = Symptom.dictionary[bodyLocation] ?? 0
            print("\n symptom id \n")
            
        default:
            id = 0
            print("\n no id \n")
        }
        return id
    }
    //    TODO:- Networking
    static func postData(url:String, parameters:[String:Any], headers:[String:String]) {
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            
            guard
                response.result.isSuccess,
                
                let value = response.result.value
            else {
                print("\n request: ", response.request!, "\n")
                print("\n response: ", response.response!, "\n")
                print("\n result: ", response.result, "\n")
                return
            }
            let data = JSON(value)
            
            MedicalDetail.token = data["Token"].stringValue
            
            print("\n Token: ", MedicalDetail.token, "\n")
        }
    }
    static func getData(url:String, parameters:[String:Any]) {
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { (response) in
            
            guard
                response.result.isSuccess,
                
                let value = response.result.value
            else {
                print("\n request: ", response.request!, "\n")
                print("\n response: ", response.response!, "\n")
                print("\n result: ", response.result, "\n")
                return
            }
            let data = JSON(value)
            
            switch url {
            case MedicalDetail.bodyAreaURL:
                diagnoseSelector = 1
                print("\n retrieving body areas \n")
                self.retrieve(data, &bodyAreas)
                
            case MedicalDetail.bodySubAreaURL:
                diagnoseSelector = 2
                print("\n retrieving body sub areas ")
                self.retrieve(data, &bodySubAreas)
                
            case Symptom.url:
                diagnoseSelector = 3
                print("\n retrieving symptoms")
                self.retrieve(data, &Symptom.dictionary)
                
            default:
                diagnoseSelector = 0
                print("\n retrieving nothing \n")
            }
        }
    }
    static func retrieve(_ data:JSON, _ dictionary:inout [String:Int]) {
        
        dictionary.removeAll()

        var name = [String]()
        var id = [Int]()
        var index = 0

        while index != data.count {

            name.append(data[index]["Name"].stringValue)
            id.append(data[index]["ID"].intValue)

            index += 1
        }
        for (key, value) in name.enumerated() {
            dictionary[value] = id[key]
            
        }
        //        TODO: Clear name and id variables to reserve memory
        name.removeAll()
        id.removeAll()
    }
    //    TODO:-
    static func getBirthYear(age: Int) -> Int {
        
        let currentYear = getCurrentYear()
        
        return currentYear - age
    }
    static func getCurrentYear() -> Int {
        
        let date = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: date)
        
        return currentYear
    }
}
