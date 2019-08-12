//
//  Menu.swift
//  Patient Medic
//
//  Created by ebuks on 14/06/2019.
//  Copyright © 2019 ebukaa. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class Menu: UITableViewController {
    
    //    MARK:- Objects
    var patient = Patient()
    
    //    MARK:- Outlet variables
    
    //    MARK:- Action functions
    @IBAction func unwindToMenu(_ unwindSegue: UIStoryboardSegue) {
        
        switch unwindSegue.identifier {
            
        case "cancel":
            print("\n Cancelled editing profile \n")
            
        default:
            break
        }
    }
    //    MARK:- Start overrides
    override func viewDidLoad() {
        super.viewDidLoad()
            
        print("\n signed in as: ", patient.email, "\n")
    }
    //    MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {

        case "appointments":
            guard
                let appointmentsScreen = segue.destination as? Appointments
            else {
                return
            }
            appointmentsScreen.patient = patient
            
        case "editProfile":
            guard
                let navigation = segue.destination as? UINavigationController,
                let profileScreen = navigation.topViewController as? EditProfile
            else {
                return
            }
            profileScreen.patient = patient

        default:
            break
        }
    }
}

// MARK:- Class methods
extension Menu {
    
}

// MARK:- delegate methods

// MARK:- UITableViewController
extension Menu {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
