//
//  Appointments.swift
//  Patient Medic
//
//  Created by ebuks on 14/06/2019.
//  Copyright © 2019 ebukaa. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import Alamofire
import SwiftyJSON

class Appointments: UITableViewController {

    //    MARK:- Objects
    var newAppointment = Appointment()
    var appointments: Results<Appointment>?
    var patient: Patient? {
        didSet {

            loadAppointments()
        }
    }
    //    MARK:- Class properties
//    var patientContactInfo = [String]()
    
    //    MARK:- Outlet variables
    
    //    MARK:- Action functions
    @IBAction func unwindToAppointments(_ unwindSegue: UIStoryboardSegue) {
        
        switch unwindSegue.identifier {
        
        case "save":
            guard
                let appointmentDetailsScreen = unwindSegue.source as? AppointmentDetails
            else {
                print("\n Could not retrieve appointment details screen \n")
                return
            }
            let appointment = appointmentDetailsScreen.appointment
            
            //            TODO: check if editing appointment
            if let selectedIndex = tableView.indexPathForSelectedRow {

                updateAppointment(selectedIndex, appointment)

                //                TODO: check if adding new appointment
            } else {
                save(appointment)
            }
            
        default:
            break
        }
    }
    
    //    MARK:- Start overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard
            let patient = patient,
            let appointments = appointments
        else {
            return
        }
        print("\n Appointments for ", patient.email, " are: ", appointments, "\n with contact info: ", patient.contactInfo, "\n")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getToken()
        
        newAppointment = Appointment()
        
        loadAppointments()
    }
    
    //    MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard
            let patient = patient
        else {
            return
        }
        switch segue.identifier {
        
        case "editAppointment":
            guard
                let appointmentDetailsScreen = segue.destination as? AppointmentDetails,
                let index = tableView.indexPathForSelectedRow,
                let appointment = appointments?[index.row]
            else {
                return
            }
            appointmentDetailsScreen.editedAppointment = appointment
            appointmentDetailsScreen.patient = patient
            
        case "addAppointment":
            
            print("\n Adding new appointment \n")
            
            guard
                let navigation = segue.destination as? UINavigationController,
                let appointmentDetailsScreen = navigation.topViewController as? AppointmentDetails
            else {
                return
            }
            appointmentDetailsScreen.patient = patient
            
        default:
            print("\n Did not go to requested screen \n")
        }
    }
}

// MARK:- Class methods
extension Appointments {
    //    TODO:- networking
    func getToken() {
        
        let tokenURL = MedicalDetail.authenticationURL + "login"
        let hmac_MD5 = tokenURL.hmac(algorithm: .md5, key: MedicalDetail.password)
        let query = [
            
            "api_key": MedicalDetail.username,
            "secret_key": MedicalDetail.password,
            "hashed_credentials": hmac_MD5
        ]
        let header = [
            
            "Authorization": "Bearer \(MedicalDetail.username):\(hmac_MD5)"
        ]
        MedicalDetail.postData(url: tokenURL, parameters: query, headers: header)
    }
    //    TODO:-
    func deleteAppointment(at index:IndexPath) {
        
        guard
            let appointment = appointments?[index.row]
        else {
            return
        }
        do {
            try realmFile.write {
                realmFile.delete(appointment)
            }
        } catch {
            print("\n Error deleting appointments from realm file: \n", error, "\n")
        }
        print("\n Appointment deleted \n")
    }
    func updateAppointment(_ index:IndexPath, _ appointment:Appointment) {
        
        guard
            let selectedAppointment = patient?.appointments[index.row]
        else {
            return
        }
        do {
            try realmFile.write {

                selectedAppointment.contactInfo = appointment.contactInfo
                selectedAppointment.location = appointment.location
                selectedAppointment.medicalDetails = appointment.medicalDetails
                selectedAppointment.time = appointment.time
            }
        } catch {
            print("\n Error updaing appointment in realm file: \n", error, "\n")
        }
        tableView.reloadRows(at: [index], with: .none)
        
        print("\n Updated appointment \n")
    }
    func loadAppointments() {
        
        guard
            let patient = patient
        else {
            return
        }
        appointments = realmFile.objects(Appointment.self).sorted(byKeyPath: "time", ascending: true).filter("patientEmail == %@", patient.email)
        
        guard
            let patientAppointments = appointments
            else {
                return
        }
        Appointment.deleteOld(patientAppointments)
        Appointment.link(to: patient, with: patientAppointments)
        
        tableView.reloadData()
    }
    func save(_ appointment:Appointment) {
        
        guard
            let patient = patient
        else {
            return
        }
        newAppointment.contactInfo = appointment.contactInfo
        newAppointment.location = appointment.location
        newAppointment.medicalDetails = appointment.medicalDetails
        newAppointment.time = appointment.time
        newAppointment.patientEmail = patient.email
        
        do {
            try realmFile.write {
                
                patient.appointments.append(newAppointment)
            }
        } catch {
            print("\n Error writing to realm file: ", error, "\n")
        }
        tableView.reloadData()
        
        print("\n Saved new appointment \n")
    }
}
// MARK:- delegate methods

// MARK:- SwipeTableViewCell
extension Appointments: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard
            orientation == .right
            else {
                return nil
        }
        let delete = SwipeAction(style: .destructive, title: nil) { (action, index) in
            
            self.deleteAppointment(at: index)
        }
        delete.image = UIImage(named: "close-circular-button-of-a-cross")
        
        return [delete]
    }
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        
        return options
    }
}

// MARK:- UITableViewController
extension Appointments {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard
            let numberOfAppointments = appointments?.count
        else {
            return 1
        }
        return numberOfAppointments
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "appointmentCell") as? AppointmentsCell,
            let appointment = appointments?[indexPath.row]
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "appointmentCell", for: indexPath)

            cell.textLabel?.text = "Error, failed to dequeue appointment cells"

            return cell
        }
        //        TODO: get swipe cell delegate
        cell.delegate = self
        
        //        TODO: update cell
        cell.update(with: appointment)
        
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 130
    }
}
