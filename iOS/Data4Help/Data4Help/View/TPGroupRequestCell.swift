//
//  TPGroupRequestCell.swift
//  Data4Help
//
//  Created by Luca Molteni on 20/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class TPGroupRequestCell: UITableViewCell {
    
    //MARK: Outlets
    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datatypesLabel: UILabel!
    @IBOutlet weak var subscriptionToggle: UISwitch!
    @IBOutlet weak var subscriptionLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    
    //Mark: properties
    var subscribing: Bool = false
    var reqid: String = ""
    var filters: [D4HHealthParameter]? = nil
    
    // Mark: functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        subscriptionToggle.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        subscriptionToggle.center.y = subscriptionLabel.center.y
        downloadButton.center.y = subscriptionLabel.center.y
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // Is it reallly D4H bound?
    func initRequest(reqid: String, groupname: String, types: [dataType], filters: [D4HHealthParameter], subscribing: Bool, duration: Float, date: String){
        self.reqid = reqid
        self.groupNameLabel.text = groupname
        self.subscribing = subscribing
        self.subscriptionToggle.isOn = subscribing
        
        var t: String = ""
        for type in types{
            t.append(type.rawValue)
        }
        
        self.filters = filters
        
        self.datatypesLabel.text = t
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
    
    @IBAction func downloadRequestData(_ sender: Any) {
        
        // API call to download request data
        NetworkManager.sharedInstance.sendPostRequest(input: D4HDownloadGroupRequest(reqID: self.reqid), endpoint: D4HEndpoint.downloadGroupRequest, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres = D4HDownloadGroupResponse(fromJson: response!)
            }
            else if let error = error {
                print(error)
            }
        }
    }
    
}
