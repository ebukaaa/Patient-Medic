//
//  AppointmentsTableViewCell.swift
//  Patient Medic
//
//  Created by ebuks on 14/06/2019.
//  Copyright © 2019 ebukaa. All rights reserved.
//

import UIKit
import SwipeCellKit

class AppointmentsCell: SwipeTableViewCell {

    //    MARK:- Objects
    
    //    MARK:- Outlet variables
    @IBOutlet weak var medicalDetail: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var contactInfo: UILabel!
    
    //    MARK:- Action functions
    
    //    MARK:- Start overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

// MARK:- Class methods
extension AppointmentsCell {
    func update(with appointment: Appointment) {
        
        medicalDetail.text = appointment.medicalDetails
        time.text = Appointment.dueDateFormat.string(from: appointment.time)
        location.text = appointment.location
        contactInfo.text = appointment.contactInfo
    }
}
