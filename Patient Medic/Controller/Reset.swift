//
//  ForgotDetails.swift
//  Patient Medic
//
//  Created by ebuks on 05/07/2019.
//  Copyright © 2019 ebukaa. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


class Reset: UITableViewController {

    //    MARK:- Objects
    var patient = Patient()
    
    //    MARK:- Outlet variables
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var resetError: UILabel!
    @IBOutlet weak var resetErrorCell: UITableViewCell!
    @IBOutlet weak var reset: UIButton!
    
    //    MARK:- Action functions
    @IBAction func resetPassword(_ sender: UIButton) {
        
        guard
            let email = email.text
        else {
            return
        }
        resetPassword(email: email)
    }
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        
        updateResetButton()
    }
    
    //    MARK:- Start overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
    }
}
    
// MARK: - Class methods
extension Reset {
    func updateResetButton() {
        
        //        TODO: login button gets enabled after all textfields are filled
        guard
            let emailText = email.text,
            
            !emailText.isEmpty
        else {
            reset.isEnabled = false
            return
        }
        reset.isEnabled = true
    }
    func resetPassword(email: String) {
        
        SVProgressHUD.show()
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            guard
                let error = error
            else {
                print("\n Sent email to reset password \n")
                
                SVProgressHUD.dismiss()
                
                self.dismiss(animated: true, completion: nil)
                return
            }
            SVProgressHUD.dismiss()
            
            self.didNotReset(email)
            
            print("\n Error reseting password: \n", error, "\n")
        }
    }
    func didNotReset(_ email:String) {
        
        resetErrorCell.isHidden = false
        resetError.textColor = .red
        
        let (alert, emailValidation) = Patient.invalidEmail()
        
        guard
            emailValidation.evaluate(with: email)
        else {
            if let errorMessage = alert.title {
                
                self.resetError.text = "\(errorMessage)"
            }
            return
        }
        Auth.auth().fetchSignInMethods(forEmail: email, completion: { (providers, error) in
            
            guard
                let _ = providers
            else {
                self.resetError.text = "Account does not exist"
                return
            }
        })
    }
    func updateView() {
        
        email.text = patient.email
        
        updateResetButton()
    }
}

// MARK:- UITableViewController
extension Reset {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
