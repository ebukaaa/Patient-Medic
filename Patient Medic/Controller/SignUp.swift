//
//  SignUp.swift
//  Patient Medic
//
//  Created by ebuks on 13/06/2019.
//  Copyright © 2019 ebukaa. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import SVProgressHUD

class SignUp: UITableViewController {

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
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var done: UIBarButtonItem!
    
    //    MARK:- Action functions
    @IBAction func doneWithSignUp(_ sender: UIBarButtonItem) {
        
        SVProgressHUD.show()
        
        //        TODO: create new user on firebase database
        Auth.auth().createUser(withEmail: patient.email, password: patient.password) { (user, error) in
            
            guard
                let error = error
            
            else {
                print("\n Patient registered to firebase \n")
                
                SVProgressHUD.dismiss()
                
                self.performSegue(withIdentifier: "doneWithSignUp", sender: self)
                return
            }
            self.didNotSignUp()
            
            print("\n Error registering to firebase: \n", error, "\n")
        }
    }
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        
        updateDoneButton()
    }
    @IBAction func showOrHideButton(_ sender: UIButton) {
    
        if isPasswordHidden {
            password.isSecureTextEntry = false
            isPasswordHidden = false
            
        } else {
            password.isSecureTextEntry = true
            isPasswordHidden = true
        }
    }
    
    //    MARK:- Start override
    override func viewDidLoad() {
        super.viewDidLoad()

        updateView()
    }
    //    MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard
            let firstName = firstName.text,
            let lastName = lastName.text,
            let address = address.text,
            let email = email.text,
            let phoneNumber = phoneNumber.text,
            let password = password.text
        else {
            return
        }
        switch segue.identifier {
        
        case "doneWithSignUp":
            guard
                let menuScreen = segue.destination as? Menu
            else {
                return
            }
            patient.firstName = firstName
            patient.lastName = lastName
            patient.address = address
            patient.email = email
            patient.phoneNumber = phoneNumber
            patient.password = password
            
            savePatient()
            
            menuScreen.patient = patient
            
        default:
            break
        }
    }
}

// MARK:- Class methods
extension SignUp {
    func didNotSignUp() {
        
        guard
            let email = email.text,
            let password = password.text
        else {
            return
        }
        Auth.auth().fetchSignInMethods(forEmail: email, completion: { (providers, error) in
            
            //            TODO: need to fixe the problem of using the transferred email & password
            if let error = error {
                print("\n Error retrieving providers: \n", error, "\n")
                
            } else if let _ = providers {
                let alert = Patient.usedEmail()
                
                self.present(alert, animated: true, completion: nil)
                
            } else if password.count < 6 {
                let alert = Patient.invalidPassword()
                
                self.present(alert, animated: true, completion: nil)
            }
        })
        SVProgressHUD.dismiss()
        
        let (alert, emailValidation) = Patient.invalidEmail()
        
        guard
            emailValidation.evaluate(with: email)
        else {
            present(alert, animated: true, completion: nil)
            return
        }
    }
    func updateView() {
        
        email.text = patient.email
        password.text = patient.password
        
        updateDoneButton()
    }
    func savePatient() {
        
        //        TODO: to firebase
        let patientData: [String: Any] = [
            
            "firstName": patient.firstName,
            "lastName": patient.lastName,
            "address": patient.address,
            "email": patient.email,
            "phoneNumber": patient.phoneNumber
        ]
        guard
            let user = Auth.auth().currentUser
        else {
            return
        }
        patientsFirestore.document(user.uid).setData(patientData) { (error) in
            
            guard
                let error = error
            else {
                print("\n Patient data saved to firebase \n")
                return
            }
            print("\n Error saving to firebase \n: ", error, "\n")
        }
        //        TODO: to realm
        do {
            try realmFile.write {
                
                realmFile.add(patient, update: .modified)
            }
        } catch {
            print("\n Error writing to realm file: ", error, "\n")
        }
    }
    func updateDoneButton() {
        
//        TODO: enable done button after all textfields are filled
        guard
            let firstnameText = firstName.text,
            let lastnameText = lastName.text,
            let addressText = address.text,
            let emailText = email.text,
            let phoneNumberText = phoneNumber.text,
            let passwordText = password.text,
            
            !firstnameText.isEmpty && !lastnameText.isEmpty && !addressText.isEmpty && !emailText.isEmpty && !phoneNumberText.isEmpty && !passwordText.isEmpty
        else {
            done.isEnabled = false
            return
        }
        done.isEnabled = true
    }
}

// MARK:- delegate methods

// MARK:- UITextField
extension SignUp: UITextFieldDelegate {
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
            password.becomeFirstResponder()
            
        } else {
            textField.resignFirstResponder()
            doneWithSignUp(done)
        }
        return true
    }
}
