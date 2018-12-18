//
//  TPRequestCell.swift
//  Data4Help
//
//  Created by Virginia Negri on 15/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class TPRequestCell: UITableViewCell {
    
    //Mark: properties
    var subscribing: Bool = false

    @IBOutlet weak var singleUserLabel: UILabel!
    @IBOutlet weak var dataTypesLabel: UILabel!
    @IBOutlet weak var subscribingSwitch: UISwitch!    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subscriptionLabel: UILabel!
    
    @IBOutlet weak var downloadButton: UIButton!
    // Mark: functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribingSwitch.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        subscribingSwitch.center.y = subscriptionLabel.center.y
        downloadButton.center.y = subscriptionLabel.center.y
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initRequest(user: String, types: [dataType], subscribing: Bool, duration: Float, date: String){
        self.singleUserLabel.text = user
        self.subscribing = subscribing
        self.subscribingSwitch.isOn = subscribing
        
        var t: String = ""
        for type in types{
            t.append(type.rawValue)
        }
        self.dataTypesLabel.text = t
        self.dateLabel.text = date
    }
    

    @IBAction func toggleSubscription(_ sender: Any) {
        if(subscribing) {
            //Send end subscription request
            subscribing = false;
            print("Subsription ended")
        }
        else {
            //Send begin subscription request
            subscribing = true
            //Done only if request accepted
        }
    }
}
