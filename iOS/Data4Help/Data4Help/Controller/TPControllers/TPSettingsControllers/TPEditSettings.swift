//
//  TPEditSettings.swift
//  Data4Help
//
//  Created by Virginia Negri on 02/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class TPEditSettings: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var pivaLabel: UILabel!
    @IBOutlet weak var companyDescriptionTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide keyboard when tap out
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    // MARK: Actions
    
    func fillView(email: String, piva: String) {
        companyNameTextField.text = ""
        emailLabel.text = email
        passwordTextField.text = ""
        pivaLabel.text = piva
        companyDescriptionTextField.text = ""
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
