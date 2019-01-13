//
//  EditSettings.swift
//  Data4Help
//
//  Created by Virginia Negri on 02/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class SUEditSettings: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var cfLabel: UILabel!
    @IBOutlet weak var birthdateTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide keyboard when tap out
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: Public implementation
    
    func fillView(email: String, cf: String) {
        fullNameTextField.text = ""
        emailLabel.text = email
        passwordTextField.text = ""
        cfLabel.text = cf
        birthdateTextField.text = ""
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
