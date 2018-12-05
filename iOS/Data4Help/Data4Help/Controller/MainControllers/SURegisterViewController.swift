//
//  SURegisterViewController.swift
//  Data4Help
//
//  Created by Virginia Negri on 30/11/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire

class SURegisterViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var fullnameTextView: UITextField!
    @IBOutlet weak var EmailTextView: UITextField!
    @IBOutlet weak var passwordTextView: UITextField!
    @IBOutlet weak var cfTextView: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: Actions
    
    
    @IBAction func CreateAccount(_ sender: Any) {
        print("sending request")
        /*let parameters: Parameters = [ "name" : "Luca",
                           "surname" : "Molteni"]
        Alamofire.request("http://127.0.0.1:3000/", method: .get, parameters : parameters, encoding: URLEncoding.default).response { response in
            print(response.data as Any)
        }*/
        //send request throw Network Manager with registration details
        print(D4HEndpoint.registerSingle)
        NetworkManager.sharedInstance.sendRequest(input: D4HRegisterRequest(email: EmailTextView.text!, password: passwordTextView.text!, FC: cfTextView.text!, fullname: fullnameTextView.text!, birthday: "", sex: ""), endpoint: D4HEndpoint.registerSingle) { (response, error) in
            if response != nil {
                let myres = D4HRegisterSingleResponse(fromJson: response!)
                print(myres.message)
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
