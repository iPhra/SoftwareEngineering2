//
//  TPViewSettings.swift
//  Data4Help
//
//  Created by Virginia Negri on 02/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class TPViewSettings: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var organisationNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var pivaLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
    }
    
    // MARK: Public implementation
    
    func fillView(info: D4HThirdPartyInfoResponse) {
        organisationNameLabel.text = info.company_name
        emailLabel.text = info.email
        pivaLabel.text = info.piva
        descriptionLabel.text = info.company_description
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
