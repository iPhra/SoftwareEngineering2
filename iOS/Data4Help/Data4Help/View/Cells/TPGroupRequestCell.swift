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
    @IBOutlet weak var filtersLabel: UILabel!
    
    
    //Mark: properties
    var subscribing: Bool = false
    var duration: Float?
    var expired: Bool = false
    var reqid: String = ""
    var filters: [D4HHealthParameter]? = nil
    var filtersToSet: String?
    
    weak var delegate: RequestCellDelegate?
    
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
    
    // Is it really D4H bound?
    func initRequest(reqid: String, groupname: String, types: [dataType], filters: [D4HHealthParameter], subscribing: Bool, duration: Float?, date: String, expired: Bool){
        self.reqid = reqid
        self.groupNameLabel.text = groupname
        self.subscribing = subscribing
        self.subscriptionToggle.isOn = subscribing && (duration != nil)
        self.subscriptionToggle.isEnabled = !expired && subscribing && (duration != nil)
        self.duration = duration
        self.expired = expired
        
        var t: String = ""
        for type in types{
            t.append(type.rawValue)
        }
        
        self.filters = filters
        initFilters(healthparameters: self.filters ?? [])
        self.filtersLabel.text = filtersToSet
        self.datatypesLabel.text = t
        self.dateLabel.text = date
    }
    
    
    @IBAction func toggleSubscription(_ sender: Any) {
        if(subscriptionToggle.isEnabled && subscribing) {
            subscribing = false;
            subscriptionToggle.isEnabled = false
            
            NetworkManager.sharedInstance.sendPostRequest(input: D4HEndSubscriptionRequest(reqID: self.reqid), endpoint: D4HEndpoint.endGroupSubscription, headers: Properties.auth()) { (response, error) in
                if response != nil {
                    let myres: D4HStatisticsResponse = D4HStatisticsResponse(fromJson: response!)
                    print(myres)
                }
                else if let error = error {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func downloadRequestData(_ sender: Any) {
        
        self.delegate?.saveCSVgroup(reqid: reqid)
        
        // API call to download request data
        /*NetworkManager.sharedInstance.sendPostRequest(input: D4HDownloadGroupRequest(reqID: self.reqid), endpoint: D4HEndpoint.downloadGroupRequest, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres = D4HDownloadGroupResponse(fromJson: response!)
            }
            else if let error = error {
                print(error)
            }
        }*/
    }
    
    func initFilters(healthparameters: [D4HHealthParameter]){
        filtersToSet = ""
        for p in healthparameters {
            filtersToSet?.append(p.datatype.rawValue)
            filtersToSet?.append(": ")
            filtersToSet?.append("min: \(p.lowerbound), max: \(p.upperbound)")
            filtersToSet?.append("\n")
        }
    }
    
}
