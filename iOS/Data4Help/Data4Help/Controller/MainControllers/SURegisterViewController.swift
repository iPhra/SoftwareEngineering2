//
//  SURegisterViewController.swift
//  Data4Help
//
//  Created by Virginia Negri on 30/11/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire

// Allow to hide in all UIControllers by tapping out of the screen
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class SURegisterViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var fullnameTextView: UITextField!
    @IBOutlet weak var EmailTextView: UITextField!
    @IBOutlet weak var passwordTextView: UITextField!
    @IBOutlet weak var cfTextView: UITextField!
    @IBOutlet weak var birthdateTextView: UITextField!
    

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
        
        let sex = DataManager.sharedInstance.getBiologicalSex()
        
        if(sex != ""){
            //send request throw Network Manager with registration details
            print(D4HEndpoint.registerSingle)
            NetworkManager.sharedInstance.sendPostRequest(input: D4HSingleRegisterRequest(email: EmailTextView.text!, password: passwordTextView.text!, FC: cfTextView.text!, fullname: fullnameTextView.text!, birthday: birthdateTextView.text!, sex: sex), endpoint: D4HEndpoint.registerSingle, headers: nil) { (response, error) in
                if response != nil {
                    let myres = D4HRegisterSingleResponse(fromJson: response!)
                    print(myres.message)
                    self.performSegue(withIdentifier: "LoginFromSU", sender: self)
                }
                else if let error = error {
                    print(error)
                    let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        else{
            let alert = UIAlertController(title: "Error", message: "You must add your biological sex in Health app", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
