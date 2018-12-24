//
//  TPRegisterViewController.swift
//  Data4Help
//
//  Created by Virginia Negri on 30/11/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class TPRegisterViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var organisationTextView: UITextField!
    @IBOutlet weak var emailTextView: UITextField!
    @IBOutlet weak var passwordTextView: UITextField!
    @IBOutlet weak var PIVATextView: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide keyboard when tap out
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
        
        // Allow to reposition views when keyboard is shown
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    //MARK: Actions
    
    @IBAction func CreateAccount(_ sender: Any) {
        print("sending request")
        
        //send request throw Network Manager with registration details
        print(D4HEndpoint.registerThirdParty)
        NetworkManager.sharedInstance.sendPostRequest(input: D4HThirdPartyRegistrationRequest(email: emailTextView.text!, password: passwordTextView.text!, PIVA: PIVATextView.text!, companyName: organisationTextView.text!, companyDescription: "TODO"), endpoint: D4HEndpoint.registerThirdParty, headers: nil) { (response, error) in
            print(response!)
            if response != nil {
                let myres = D4HRegisterSingleResponse(fromJson: response!)
                print(myres)
                self.performSegue(withIdentifier: "LoginFromTP", sender: self)
            }
            else if let error = error {
                print(error)
            }
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
