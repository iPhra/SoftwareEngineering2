//
//  MyCell.swift
//  Data4Help
//
//  Created by Virginia Negri on 14/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class MyCell: UITableViewCell {
    
    // Mark: Labels
    
    @IBOutlet weak var labelCompany: UILabel!
    @IBOutlet weak var labelSubscribing: UILabel!    
    @IBOutlet weak var labelDatatypes: UILabel!
    
    // Mark: Properties
    
    var reqID: String = ""
    var companyName: String = ""
    var dataTypes: [dataType] = []
    var subscribing: Bool = false
    var duration: Float = 0
    
    // Mark: initializers
    
    func initRequest(reqID: String, senderID: String, types: [dataType], subscribing: Bool, duration: Float){
        self.reqID = reqID
        self.companyName = senderID
        self.dataTypes = types
        self.subscribing = subscribing
        self.duration = duration
        
        self.labelCompany.text = senderID
        
        if(subscribing){
            self.labelSubscribing.text = "YES"
        }
        else{
            self.labelSubscribing.text = "NO"
        }
        
        var t:String = ""
        for type in types{
            t.append(type.rawValue)
        }
        self.labelDatatypes.text = t
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
            }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
