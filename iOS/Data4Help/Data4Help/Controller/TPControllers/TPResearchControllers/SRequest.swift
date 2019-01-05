//
//  SRequestViewController.swift
//  Data4Help
//
//  Created by Virginia Negri on 02/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class SRequest: UIViewController {
    
    // Mark: Properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var CFTextField: UITextField!
    
    @IBOutlet weak var heartRateSwitch: UISwitch!
    
    @IBOutlet weak var stepsSwitch: UISwitch!
    
    @IBOutlet weak var bloodPressureSwitch: UISwitch!
    
    @IBOutlet weak var activeEnergyBurnedSwitch: UISwitch!
    
    @IBOutlet weak var sleepingHoursSwitch: UISwitch!
    
    @IBOutlet weak var heightSwitch: UISwitch!
    
    @IBOutlet weak var standingHoursSwitch: UISwitch!
    
    @IBOutlet weak var weightSwitch: UISwitch!
    
    @IBOutlet weak var subscriptionSwitch: UISwitch!
    
    @IBOutlet weak var durationTextField: UITextField!
    // Mark: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 50)
        
        emailTextField.text = ""
        CFTextField.text = ""
        durationTextField.text = ""
    }
    
    @IBAction func sendRequest(_ sender: Any) {
        
        NetworkManager.sharedInstance.sendPostRequest(input: D4HSingleRequest(email: emailTextField.text!, fc: CFTextField.text!, types: getDataTypesToSend(), subscribing: subscriptionSwitch.isOn, duration: Int(durationTextField.text!) ?? 0), endpoint: D4HEndpoint.singleRequest, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres = D4HSingleResponse(fromJson: response!)
                print(myres.message)
            }
            else if let error = error {
                print(error)
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func getDataTypesToSend() -> [String]{
        var dataTypesToSend : [String] = []
        if(heartRateSwitch.isOn) { dataTypesToSend.append(dataType.heartrate.rawValue)}
        if(activeEnergyBurnedSwitch.isOn) { dataTypesToSend.append(dataType.activeEnergyBurned.rawValue)}
        if(sleepingHoursSwitch.isOn) { dataTypesToSend.append(dataType.sleepingHours.rawValue)}
        if(heightSwitch.isOn) { dataTypesToSend.append(dataType.height.rawValue)}
        if(weightSwitch.isOn) { dataTypesToSend.append(dataType.weight.rawValue)}
        if(standingHoursSwitch.isOn) { dataTypesToSend.append(dataType.standingHours.rawValue)}
        if(bloodPressureSwitch.isOn){
            dataTypesToSend.append(dataType.systolic_pressure.rawValue)
            dataTypesToSend.append(dataType.diastolic_pressure.rawValue)
        }
        if(stepsSwitch.isOn) { dataTypesToSend.append(dataType.steps.rawValue)}
        return dataTypesToSend
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
