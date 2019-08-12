//
//  Symptoms.swift
//  Patient Medic
//
//  Created by ebuks on 07/07/2019.
//  Copyright © 2019 ebukaa. All rights reserved.
//

import UIKit
import RealmSwift

class Symptoms: UITableViewController {

    //    MARK:- Objects
    var symptom = Symptom()
    var symptoms: Results<Symptom>?
    var appointment: Appointment? {
        didSet {
            
            loadSymptoms()
        }
    }
    
    //    MARK:- Outlet variables
    @IBOutlet weak var search: UISearchBar!
    
    //    MARK:- Action functions
    
    //    MARK:- Start overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {

        loadSymptoms()
    }
//        MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard
            let bodyAreaScreen = segue.destination as? SelectBodyArea
            else {
                return
        }
        bodyAreaScreen.delegate = self
    }
}

// MARK;- Class methods
extension Symptoms {
    func loadSymptoms() {
        
        guard
            let appointment = appointment
            else {
                return
        }
        symptoms = realmFile.objects(Symptom.self).sorted(byKeyPath: "id", ascending: true).filter("patientEmail == %@", appointment.patientEmail)
        
        guard
            let patientSymptoms = symptoms
            else {
                return
        }
        Symptom.link(to: appointment, with: patientSymptoms)
    }
    
}

// MARK:- Delegate methods

// MARK:- Symptom
extension Symptoms: SymptomDelegate {
    func saveSymptom() {

        print("\n entered save symptom method \n")

        guard
            let patientSymptoms = symptoms,
            let appointment = appointment

            else {
                return
        }
        print("\n passs guard \n")

        do {
            try realmFile.write {

                realmFile.delete(patientSymptoms)
            }
        } catch {
            print("\n Error deleting appointments from realm file: \n", error, "\n")
        }
        for (key, value) in Symptom.dictionary {
            let newSymptom = Symptom()
            newSymptom.name = key
            newSymptom.id = value
            newSymptom.patientEmail = appointment.patientEmail

            do {
                try realmFile.write {

                    appointment.medicalDetail?.symptoms.append(newSymptom)
                }
            } catch {
                print("\n Error writing to realm file: ", error, "\n")
            }
        }
        tableView.reloadData()

        print("\n Saved new appointment \n")
    }
}
// MARK:- UISearchBar
extension Symptoms: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard
            let search = searchBar.text
        else {
            return
        }
        
    }
}

// MARK: UITableViewController
extension Symptoms {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard
            let numberOfSymptoms = symptoms?.count
            else {
                return 1
        }

        return numberOfSymptoms
//        return Symptom.names.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "symptomCell"),
            let symptom = symptoms?[indexPath.row]
            
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "symptomCell", for: indexPath)
            
            cell.textLabel?.text = "Error, failed to dequeue appointment cells"
            
            return cell
        }

        // Configure the cell...
        cell.textLabel?.text = symptom.name
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
            
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        
    }
}
