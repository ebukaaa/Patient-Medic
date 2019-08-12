//
//  EditProfile.swift
//  Patient Medic
//
//  Created by ebuks on 28/06/2019.
//  Copyright © 2019 ebukaa. All rights reserved.
//

import UIKit
import Firebase

class EditProfile: UITableViewController {

    //    MARK:- Objects
    var patient = Patient()
    
    //    MARK:- Class properties
    var isPasswordHidden = true
    
    //    MARK:- Outlet variables
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var repeatedPassword: UITextField!
    @IBOutlet weak var save: UIBarButtonItem!
    
    //    MARK:- Action functions
    @IBAction func showOrHidePassword(_ sender: UIButton) {
        
        if isPasswordHidden {
            newPassword.isSecureTextEntry = false
            repeatedPassword.isSecureTextEntry = false
            isPasswordHidden = false
            
        } else {
            newPassword.isSecureTextEntry = true
            repeatedPassword.isSecureTextEntry = true
            isPasswordHidden = true
        }
    }
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {

        updateSaveButton()
    }
    @IBAction func saveProfile(_ sender: UIBarButtonItem) {
        
        guard
            let email = email.text
        else {
            return
        }
        isEmailValid(email)
        
        Auth.auth().fetchSignInMethods(forEmail: email, completion: { (providers, error) in
            
            self.isEmailUsed(providers, email)
            
            self.checkPasswordLength()
            
            self.trySaving()
        })
    }
    
    //    MARK:- Start overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
    }
    //    MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard
            let menuScreen = segue.destination as? Menu
        else {
            return
        }
        menuScreen.patient = patient
    }
}
// MARK:- Class methods
extension EditProfile {
    func trySaving() {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Enter password", message: "", preferredStyle: .alert)
        let save = UIAlertAction(title: "Save", style: .default) { (action) in
            
            if let text = textField.text,
                self.patient.password == text {
                
                self.updatePatient()
                self.dismiss(animated: true, completion: nil)
                
            } else {
                let alert = Patient.alertControl()
                alert.title = "Wrong password"
                
                self.present(alert, animated: true, completion: nil)
                
                print("\n Profile didn't change \n")
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { (alertTextField) in
            
            textField = alertTextField
            textField.placeholder = "Old password"
            textField.isSecureTextEntry = true
        }
        alert.addAction(save)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    func checkPasswordLength() {
        
        guard
            let newPassword = self.newPassword.text,
            let repeatedPassword = self.repeatedPassword.text
            else {
                return
        }
        if !newPassword.isEmpty && newPassword.count < 6 {
            let alert = Patient.invalidPassword()
            
            present(alert, animated: true, completion: nil)
            
        } else if repeatedPassword != newPassword {
            let alert = Patient.alertControl()
            alert.title = "New password in both fields must match"
            
            present(alert, animated: true, completion: nil)
        }
    }
    func isEmailUsed(_ providers:[String]?, _ email:String) {
        
        if let _ = providers,
            self.patient.email != email {
            let alert = Patient.usedEmail()
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    func isEmailValid(_ email:String) {
        
        let (alert, emailValidation) = Patient.invalidEmail()
        
        guard
            emailValidation.evaluate(with: email)
        else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    func updateView() {
        
        firstName.text = patient.firstName
        lastName.text = patient.lastName
        address.text = patient.address
        email.text = patient.email
        phoneNumber.text = patient.phoneNumber
        
        updateSaveButton()
    }
    func updateSaveButton() {
        
        let firstNameText = firstName.text ?? ""
        let lastNameText = lastName.text ?? ""
        let addressText = address.text ?? ""
        let emailText = email.text ?? ""
        let phoneNumberText = phoneNumber.text ?? ""
        let newPasswordText = newPassword.text ?? ""
        let repeatedPasswordText = repeatedPassword.text ?? ""
        
        //        TODO: done bar button gets enabled after all textfields are filled
        guard
            !firstNameText.isEmpty && firstNameText != patient.firstName ||
            !lastNameText.isEmpty && lastNameText != patient.lastName ||
            !addressText.isEmpty && addressText != patient.address ||
            !emailText.isEmpty && emailText != patient.email ||
            !phoneNumberText.isEmpty && phoneNumberText != patient.phoneNumber
        ||
            (!newPasswordText.isEmpty && newPasswordText != patient.password &&
            !repeatedPasswordText.isEmpty && repeatedPasswordText != patient.password)
        else {
            save.isEnabled = false
            return
        }
        save.isEnabled = true
    }
    func updatePatient() {
        
        guard
            let firstName = firstName.text,
            let lastName = lastName.text,
            let address = address.text,
            let email = email.text,
            let phoneNumber = phoneNumber.text,
            let password = newPassword.text,
            let user = Auth.auth().currentUser
        else {
            return
        }
        //        TODO: update realm
        do {
            try realmFile.write {
                
                patient.firstName = firstName
                patient.lastName = lastName
                patient.address = address
                patient.email = email
                patient.phoneNumber = phoneNumber
            }
        } catch {
            print("\n Error updating patient to realm file: \n", error, "\n")
        }
        for appointment in patient.appointments {
            do {
                try realmFile.write {
                    
                    appointment.patientEmail = patient.email
                }
            } catch {
                print("\n Error updaing appointment in realm file: \n", error, "\n")
            }
        }
        //        TODO: update firebase
        let patientData:[String: Any] = [
            
            "firstName": patient.firstName,
            "lastName": patient.lastName,
            "address": patient.address,
            "phoneNumber": patient.phoneNumber,
        ] 
        patientsFirestore.document(user.uid).updateData(patientData)
        
        user.updateEmail(to: patient.email) { (error) in
            
            guard
                let error = error
            else {
                patientsFirestore.document(user.uid).updateData(["email": self.patient.email])
                
                print("\n Email updated in firebase \n")
                return
            }
            print("\n Error updating email to firebase: \n", error, "\n")
        }
        user.updatePassword(to: password) { (error) in
            
            guard
                let error = error
            else {
                print("\n Password updated in firebase \n")
                return
            }
            print("\n Error updating password in firebase: \n", error, "\n")
        }
        print("\n Profile edited \n")
    }
}

// MARK:- delegate methods

// MARK:- UITableViewController
extension EditProfile {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: UITextField
extension EditProfile: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstName {
            textField.resignFirstResponder()
            lastName.becomeFirstResponder()
            
        } else if textField == lastName {
            textField.resignFirstResponder()
            address.becomeFirstResponder()
            
        } else if textField == address {
            textField.resignFirstResponder()
            email.becomeFirstResponder()
            
        } else if textField == email {
            textField.resignFirstResponder()
            phoneNumber.becomeFirstResponder()
            
        } else if textField == phoneNumber {
            textField.resignFirstResponder()
            newPassword.becomeFirstResponder()
            
        } else if textField == newPassword {
            textField.resignFirstResponder()
            repeatedPassword.becomeFirstResponder()
            
        } else {
            textField.resignFirstResponder()
            saveProfile(save)
        }
        return true
    }
}
