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
    var reqid: String = ""
    
    weak var delegate: RequestCellDelegate?

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
    
    func initRequest(reqid: String, user: String, types: [dataType], subscribing: Bool, duration: Float?, date: String, expired: Bool){
        self.reqid = reqid
        self.singleUserLabel.text = user
        self.subscribing = subscribing
        self.subscribingSwitch.isOn = subscribing && (duration != nil)
        self.subscribingSwitch.isEnabled = !expired && subscribing && (duration != nil)
        
        var t: String = ""
        for type in types{
            t.append(type.rawValue)
        }
        self.dataTypesLabel.text = t
        self.dateLabel.text = date
    }
    

    @IBAction func toggleSubscription(_ sender: Any) {
        if(subscribingSwitch.isEnabled && subscribing) {
            
            NetworkManager.sharedInstance.sendPostRequest(input: D4HEndSubscriptionRequest(reqID: self.reqid), endpoint: D4HEndpoint.endSingleSubscription, headers: Properties.auth()) { (response, error) in
                if response != nil {
                    let myres: D4HStatisticsResponse = D4HStatisticsResponse(fromJson: response!)
                    print(myres)
                    self.subscribing = false;
                    self.subscribingSwitch.isEnabled = false
                }
                else if let error = error {
                    print(error)
                    var parentViewController: UIViewController? {
                        var parentResponder: UIResponder? = self
                        while parentResponder != nil {
                            parentResponder = parentResponder!.next
                            if parentResponder is UIViewController {
                                return parentResponder as! UIViewController!
                            }
                        }
                        return nil
                    }
                    let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    parentViewController!.present(alert, animated: true, completion: nil)
                    self.subscribingSwitch.isOn = true
                }
            }
        }
    }
    
    @IBAction func downloadRequestData(_ sender: Any) {
        
        self.delegate?.saveCSVsingle(reqid: reqid)
        
        // API call to download request data
        /*NetworkManager.sharedInstance.sendPostRequest(input: D4HDownloadSingleRequest(reqID: self.reqid), endpoint: D4HEndpoint.downloadSingleRequest, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres = D4HDownloadSingleResponse(fromJson: response!)
            }
            else if let error = error {
                print(error)
            }
        }*/
    }
    
}
