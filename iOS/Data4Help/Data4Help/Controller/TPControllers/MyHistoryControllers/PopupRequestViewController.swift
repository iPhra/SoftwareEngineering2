//
//  PopupRequestViewController.swift
//  Data4Help
//
//  Created by Virginia Negri on 06/01/2019.
//  Copyright © 2019 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class PopupRequestViewController: UIViewController {
    
    @IBOutlet weak var requestTitle: UILabel!
    var titleToSet: String?
    
    
    @IBOutlet weak var dateLabel: UILabel!
    var dateToSet: String?
    
    @IBOutlet weak var datatypesLabel: UILabel!
    var datatypesToSet: String?
    
    @IBOutlet weak var subscribingLabel: UILabel!
    var subscribing: String?
    
    
    @IBOutlet weak var durationLabel: UILabel!
    var durationToSet: String?
    
    @IBOutlet weak var expiredLabel: UILabel!
    var expired: String?
    
    var filtersToSet: String?
    
    @IBOutlet weak var filtersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestTitle!.text = titleToSet ?? "Request"
        self.datatypesLabel!.text = datatypesToSet ?? "Data types"
        self.subscribingLabel!.text = subscribing ?? "No"
        self.dateLabel!.text = dateToSet ?? "Date"
        self.durationLabel!.text = durationToSet ?? "0"
        self.expiredLabel!.text = expired ?? "No"
        self.filtersLabel!.text = filtersToSet ?? "No filters"
    }
    
    func initPopup(title: String?, datatypes: String?, subscribing: Bool, date: String?, duration: Float?, expired: Bool){
        self.titleToSet = title
        self.datatypesToSet = datatypes
        self.subscribing = subscribing ? "Yes" : "No"
        self.dateToSet = date
        self.durationToSet = String(duration ?? 0)
        self.expired = expired ? "Yes" : "No"
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
