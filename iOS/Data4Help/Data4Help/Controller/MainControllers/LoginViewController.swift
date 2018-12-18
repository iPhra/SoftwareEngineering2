//
//  LoginViewController.swift
//  Data4Help
//
//  Created by Virginia Negri on 26/11/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide keyboard when tap out
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // DEBUGGING FUNCTIONS
        // DELETE BEFORE DEPLOYMENT
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        view.addGestureRecognizer(swipe)
    }
    
    // MARK: Actions
    @IBAction func loginUser(_ sender: UIButton) {
        guard  usernameTextField.text != nil && passwordTextField.text != nil else {
            return
        }
        
        print("Sending login request")
        
        //send request through Network Manager with login details
        print(D4HEndpoint.login)
        NetworkManager.sharedInstance.sendPostRequest(input: D4HLoginRequest(email: usernameTextField.text!, password: passwordTextField.text!), endpoint: D4HEndpoint.login, headers: nil) { (response, error) in
            if response != nil {
                let myres = D4HLoginResponse(fromJson: response!)
                print(myres.message)
                
                // Set authToken for the logged user
                Properties.authToken = myres.authToken
                print(Properties.authToken)
                // Perform segue either to Single user or Third Party interface
                if myres.userType == "PrivateUser" {
                    self.performSegue(withIdentifier: "GoToSingleUser", sender: self)
                } else {
                    self.performSegue(withIdentifier: "GoToThirdParty", sender: self)
                }
                
            }
            else if let error = error {
                print(error)
            }
        }
        
    }
    
    // MARK: debugging functions
    // TO be deleted before deployment
    
    @objc func doubleTapped() {
        // do something here
        print("Secret login to third party")
        guard  usernameTextField.text != nil && passwordTextField.text != nil else {
            return
        }
        
        print("Sending login request")
        
        //send request through Network Manager with login details
        print(D4HEndpoint.login)
        NetworkManager.sharedInstance.sendPostRequest(input: D4HLoginRequest(email: "gruosso_industries@gmail.com", password: "asasasas"), endpoint: D4HEndpoint.login, headers: nil) { (response, error) in
            if response != nil {
                let myres = D4HLoginResponse(fromJson: response!)
                print(myres.message)
                
                // Set authToken for the logged user
                Properties.authToken = myres.authToken
                print(Properties.authToken)
                // Perform segue either to Single user or Third Party interface
                if myres.userType == "PrivateUser" {
                    self.performSegue(withIdentifier: "GoToSingleUser", sender: self)
                } else {
                    self.performSegue(withIdentifier: "GoToThirdParty", sender: self)
                }
                
            }
            else if let error = error {
                print(error)
            }
        }
    }

    @objc func swiped() {
        // do something here
        print("Secret login to single user")
        guard  usernameTextField.text != nil && passwordTextField.text != nil else {
            return
        }
        
        print("Sending login request")
        
        //send request through Network Manager with login details
        print(D4HEndpoint.login)
        NetworkManager.sharedInstance.sendPostRequest(input: D4HLoginRequest(email: "moltek96@gmail.com", password: "datahelp"), endpoint: D4HEndpoint.login, headers: nil) { (response, error) in
            if response != nil {
                let myres = D4HLoginResponse(fromJson: response!)
                print(myres.message)
                
                // Set authToken for the logged user
                Properties.authToken = myres.authToken
                print(Properties.authToken)
                // Perform segue either to Single user or Third Party interface
                if myres.userType == "PrivateUser" {
                    self.performSegue(withIdentifier: "GoToSingleUser", sender: self)
                } else {
                    self.performSegue(withIdentifier: "GoToThirdParty", sender: self)
                }
                
            }
            else if let error = error {
                print(error)
            }
        }
    }
    
}

