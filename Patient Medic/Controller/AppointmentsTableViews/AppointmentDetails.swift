//
//  AppointmentDetails.swift
//  Patient Medic
//
//  Created by ebuks on 14/06/2019.
//  Copyright © 2019 ebukaa. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AppointmentDetails: UITableViewController {

    //    MARK:- Objects
    var editedAppointment: Appointment?
    var appointment = Appointment()
    var patient = Patient()
    
    //    MARK:- Class properties
    var isDatePickerHidden = true
    var isLocationPickerHidden = true
    var isContactPickerHidden = true
    
    //    MARK:- Outlet variables
    @IBOutlet weak var medicalDetail: UITextView!
    @IBOutlet weak var save: UIBarButtonItem!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var contactInfo: UILabel!
    @IBOutlet weak var timeDatePicker: UIDatePicker!
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var contactPicker: UIPickerView!
    
    //    MARK:- Action functions
    @IBAction func unwindToAppointmentDetails(_ unwindSegue: UIStoryboardSegue) {
        
    }
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        
        updateDueDate(timeDatePicker.date)
        updateSaveButton()
    }
    
    //    MARK:- Start overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\n contact info: ", patient.contactInfo, "\n")
        
        updateView()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        getBodyArea()
    }
    
    //    MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier {
        
        case "save", "medicalDetails":
            
            print("\n preparing to move from details to appointments screen \n")
            guard
                let medicalDetailText = medicalDetail.text,
                let locationText = location.text,
                let contactInfoText = contactInfo.text,
                let bodyAreaScreen = segue.destination as? SelectBodyArea
            else {
                return
            }
            appointment.medicalDetails = medicalDetailText
            appointment.time = timeDatePicker.date
            appointment.location = locationText
            appointment.contactInfo = contactInfoText
            appointment.patientEmail = patient.email
            
            bodyAreaScreen.appointment = appointment
            
        case "cancel":
            print("\n Cancelled and returned to appointments screen \n")
            
        default:
            break
        }
    }
}

// MARK:- Class methods
extension AppointmentDetails {
    //    TODO:- networking
    func getBodyArea() {
        
        MedicalDetail.bodyAreaURL = MedicalDetail.healthURL + "body/locations"
        let query: [String:Any] = [
            
            "token": MedicalDetail.token,
            "language": MedicalDetail.language
        ]
        MedicalDetail.getData(url: MedicalDetail.bodyAreaURL, parameters: query)
    }
    //    TODO:- updating
    func updateDueDate(_ date: Date) {
        
        dueDate.text = Appointment.dueDateFormat.string(from: date)
    }
    func updateView() {
        
        if let selectedAppointment = editedAppointment {
            medicalDetail.text = selectedAppointment.medicalDetails
            timeDatePicker.date = selectedAppointment.time
            location.text = selectedAppointment.location
            contactInfo.text = selectedAppointment.contactInfo
            
        } else {
            timeDatePicker.date = Appointment.minimumTime()
            
            location.text = Appointment.locations[0]
            contactInfo.text = patient.contactInfo[0]
        }
        timeDatePicker.minimumDate = Appointment.minimumTime()
        timeDatePicker.maximumDate = Appointment.maximumTime()
        
        updateDueDate(timeDatePicker.date)
        updateSaveButton()
    }
    func updateSaveButton() {
        
        let medicalDetailText = medicalDetail.text ?? ""
        let dueDateText = dueDate.text ?? ""
        let locationText = location.text ?? ""
        let contactInfoText = contactInfo.text ?? ""
        
        if let selectedAppointment = editedAppointment {
            guard
                (!medicalDetailText.isEmpty && medicalDetailText != selectedAppointment.medicalDetails ||
                dueDateText != Appointment.dueDateFormat.string(from: selectedAppointment.time) ||
                locationText != selectedAppointment.location ||
                contactInfoText != selectedAppointment.contactInfo)
            &&
                (!locationText.contains(Appointment.locations[0]) && !contactInfoText.contains(patient.contactInfo[0]))
            else {
                save.isEnabled = false
                return
            }
            save.isEnabled = true
            
        } else {
            guard
                !medicalDetailText.isEmpty && !locationText.contains(Appointment.locations[0]) &&
                    !contactInfoText.contains(patient.contactInfo[0])
            else {
                save.isEnabled = false
                return
            }
            save.isEnabled = true
        }
    }
}

// MARK:- Delegate methods

// MARK:- UIPickerView
extension AppointmentDetails: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView.tag {
        
        case 1:
            return Appointment.locations.count
            
        case 2:
            return patient.contactInfo.count
            
        default:
            return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView.tag {
        
        case 1:
            return Appointment.locations[row]
            
        case 2:
            return patient.contactInfo[row]
            
        default:
            return "No information available"
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        
        case 1:
            location.text = Appointment.locations[row]
            
        case 2:
            contactInfo.text = patient.contactInfo[row]
            
        default:
            break
        }
        updateSaveButton()
    }
}

// MARK: UITextView
extension AppointmentDetails: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        updateSaveButton()
    }
}

// MARK: UITableView
extension AppointmentDetails {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let normalCellHeight = CGFloat(40)
        let largeCellHeight = CGFloat(200)
        
        switch indexPath {

        //        TODO: medical text view cell
        case [0, 1]:
            return largeCellHeight

        //        TODO: due date cell
        case [1, 0]:
            return isDatePickerHidden ? normalCellHeight : largeCellHeight

        //        TODO: location picker cell
        case [2, 0]:
            return isLocationPickerHidden ? normalCellHeight : largeCellHeight
            
        //        TODO: contact pciker cell
        case [3, 0]:
            return isContactPickerHidden ? normalCellHeight : largeCellHeight

        default:
            return tableView.rowHeight
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        
        //        TODO: due date cell
        case [1, 0]:
            isDatePickerHidden = !isDatePickerHidden
            
            dueDate.textColor = isDatePickerHidden ? .black : tableView.tintColor
            
        //        TODO: location picker cell
        case [2, 0]:
            isLocationPickerHidden = !isLocationPickerHidden

            location.textColor = isLocationPickerHidden ? .black : tableView.tintColor
            
        //        TODO: contact picker cell
        case [3, 0]:
            isContactPickerHidden = !isContactPickerHidden
            
            contactInfo.textColor = isContactPickerHidden ? .black : tableView.tintColor
            
        default:
            break
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
