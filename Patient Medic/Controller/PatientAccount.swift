//
//  ViewController.swift
//  Patient Medic
//
//  Created by ebuks on 13/06/2019.
//  Copyright © 2019 ebukaa. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import SVProgressHUD

class PatientAccount: UITableViewController {
    
    //    MARK:- Objects
    var patient = Patient()
    
    //    MARK:- Outlet variables
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var loginError: UILabel!
    @IBOutlet weak var loginErrorCell: UITableViewCell!
    
    //    MARK:- Action functions
    @IBAction func loginToAccount(_ sender: UIButton) {
        
        guard
            let email = email.text,
            let password = password.text
        else {
            return
        }
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            guard
                let error = error
            else {
                print(" \n Login successful \n")
                
                SVProgressHUD.dismiss()
                
                self.performSegue(withIdentifier: "login", sender: self)
                return
            }
            self.didNotLogin(email)
            
            print("\n Error logging in: \n", error, "\n")
        }
    }
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        
        updateLoginButton()
    }
    @IBAction func unwindToPatientAccount(_ unwindSegue: UIStoryboardSegue) {
        
        switch unwindSegue.identifier {
        
        case "logout":
            do {
                try Auth.auth().signOut()

                print("\n Logged out of account \n")

            } catch {
                print("\n There was a problem signing out \n")
            }
            
        default:
            break
        }
        updateView()
    }
    //    MARK:- Start overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLoginButton()
    }
    override func viewWillAppear(_ animated: Bool) {

        patient = Patient()
    }
    //    MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard
            let email = email.text,
            let password = password.text
        else {
            return
        }
        patient.email = email
        patient.password = password
        
        switch segue.identifier {
        
        case "signUp":
            guard
                let navigation = segue.destination as? UINavigationController,
                let signUpScreen = navigation.topViewController as? SignUp
            else {
                return
            }
            signUpScreen.patient = patient
            
        case "login":
            guard
                let menuScreen = segue.destination as? Menu
            else {
                return
            }
            loadPatient()
            menuScreen.patient = patient
            
        case "forgotDetails":
            guard
                let navigation = segue.destination as? UINavigationController,
                let resetScreen = navigation.topViewController as? Reset
            else {
                return
            }
            resetScreen.patient = patient
            
        default:
            break
        }
    }
}

// MARK:- Class methods
extension PatientAccount {
    func updateView() {
        
        password.text = ""
        loginError.text = "-"
        loginErrorCell.isHidden = true
        
        updateLoginButton()
    }
    func didNotLogin(_ email:String) {
        
        loginErrorCell.isHidden = false
        loginError.textColor = .red
        
        Auth.auth().fetchSignInMethods(forEmail: email, completion: { (providers, error) in
            
            if let _ = providers {
                self.loginError.text = "Password does not match"
                
            } else if let error = error {
                print("\n Error retrieving providers: \n", error, "\n")
                
            } else {
                self.loginError.text = "Account does not exist"
            }
        })
        SVProgressHUD.dismiss()
        
        let (alert, emailValidation) = Patient.invalidEmail()
        
        if let errorMessage = alert.title,
            !emailValidation.evaluate(with: email) {
            
            loginError.text = "\(errorMessage)"
        }
    }
    func loadPatient() {
        
        guard
            let user = Auth.auth().currentUser
        else {
            return
        }
        //        TODO: from firebase
        let patientData = patientsFirestore.document(user.uid)
        patientData.getDocument(source: .default) { (document, error) in
            
            guard
                let data = document?.data(),
                let firstName = data["firstName"] as? String,
                let lastName = data["lastName"] as? String,
                let address = data["address"] as? String,
                let email = data["email"] as? String,
                let phoneNumber = data["phoneNumber"] as? String
                else {
                    return
            }
            self.patient.firstName = firstName
            self.patient.lastName = lastName
            self.patient.address = address
            self.patient.email = email
            self.patient.phoneNumber = phoneNumber
            
            //            TODO: save to realm
            self.save(self.patient)
            
            print("\n Loaded patient data from firebase \n")
        }
    }
    func save(_ patient:Patient) {
        
        do {
            try realmFile.write {
                
                realmFile.add(patient, update: .modified)
            }
        } catch {
            print("\n Error writing to realm file: \n", error, "\n")
        }
    }
    func updateLoginButton() {
        
        //        TODO: login button gets enabled after all textfields are filled
        guard
            let emailText = email.text,
            let passwordText = password.text,
        
            !emailText.isEmpty && !passwordText.isEmpty
        else {
            login.isEnabled = false
            return
        }
        login.isEnabled = true
    }
}

// MARK:- delegate methods

// MARK:- UITextField
extension PatientAccount: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == email {
            textField.resignFirstResponder()
            password.becomeFirstResponder()
            
        } else {
            textField.resignFirstResponder()
            loginToAccount(login)
        }
        return true
    }
}
// MARK:- UITableViewController
extension PatientAccount {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
