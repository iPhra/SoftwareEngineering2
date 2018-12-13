//
//  MyFollowers.swift
//  Data4Help
//
//  Created by Virginia Negri on 13/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class RequestCell: UITableViewCell{
    var reqID: String = ""
    var senderID: String = ""
    var types: [dataType] = []
    var subscribing: Bool = false
    var duration: Float = 0
    
    func initRequest(reqID: String, senderID: String, types: [dataType], subscribing: Bool, duration: Float){
        self.reqID = reqID
        self.senderID = senderID
        self.types = types
        self.subscribing = subscribing
        self.duration = duration
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}


class MyFollowers: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
