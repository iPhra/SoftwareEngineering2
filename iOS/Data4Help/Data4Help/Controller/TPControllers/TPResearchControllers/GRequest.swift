//
//  GRequest.swift
//  Data4Help
//
//  Created by Virginia Negri on 02/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit

class GRequest: UIViewController {
    
    // Mark: Properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let parameters: [String] = [dataType.age.rawValue, dataType.weight.rawValue, dataType.heartrate.rawValue, dataType.sleepingHours.rawValue]
    
    // Mark: Sliders
    
    @IBOutlet weak var minAgeSlider: UISlider!
    
    @IBOutlet weak var maxAgeSlider: UISlider!
    
    @IBOutlet weak var minWeightSlider: UISlider!
    
    @IBOutlet weak var maxWeightSlider: UISlider!
    
    // Mark: Switches
    
    @IBOutlet weak var heartRateSwitch: UISwitch!
    
    @IBOutlet weak var activeEnergyBurnedSwitch: UISwitch!
    
    @IBOutlet weak var bloodPressureSwitch: UISwitch!
    
    @IBOutlet weak var stepsSwitch: UISwitch!
    
    @IBOutlet weak var sleepingHoursSwitch: UISwitch!
    
    @IBOutlet weak var standingHoursSwitch: UISwitch!
    
    @IBOutlet weak var heightSwitch: UISwitch!
    
    @IBOutlet weak var weightSwitch: UISwitch!    
    
    @IBOutlet weak var subscriptionSwitch: UISwitch!
    
    // Mark: Subscription TextField
    
    @IBOutlet weak var durationTextField: UITextField!
    
    // Mark: Buttons
    
    @IBOutlet weak var sendRequestButton: UIButton!
    
    // Slider Labels
    
    @IBOutlet weak var minAgeSliderText: UILabel!
    
    @IBOutlet weak var maxAgeSliderText: UILabel!
    
    @IBOutlet weak var minWeightSliderText: UILabel!
    
    @IBOutlet weak var maxWeightSliderText: UILabel!
    
    // Filters TextFields
    
    @IBOutlet weak var minBPMTextField: UITextField!
    
    @IBOutlet weak var maxBPMTextField: UITextField!
    
    @IBOutlet weak var minSleepingHoursTextField: UITextField!
    
    @IBOutlet weak var maxSleepingHoursTextField: UITextField!
    
    // Mark: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide keyboard when tap out
        self.hideKeyboardWhenTappedAround()

        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 500)
        
        minAgeSliderText.text = ""
        maxAgeSliderText.text = ""
        minWeightSliderText.text = ""
        maxWeightSliderText.text = ""
        minBPMTextField.text = ""
        maxBPMTextField.text = ""
        durationTextField.text = ""
        minSleepingHoursTextField.text = ""
        maxSleepingHoursTextField.text = ""
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Send a group request
    @IBAction func sendRequest(_ sender: Any) {
        
        NetworkManager.sharedInstance.sendPostRequest(input: D4HGroupRequest(types: getDataTypesToSend(), parameters: self.parameters, bounds: getBounds(), subscribing: subscriptionSwitch.isOn, duration: Int(durationTextField.text!) ?? 0), endpoint: D4HEndpoint.groupRequest, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres = D4HGroupResponse(fromJson: response!)
                print(myres.message)
                let alert = UIAlertController(title: "Message", message: "Request sent!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.resetRequest()
            }
            else if let error = error {
                print(error)
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func resetRequest(){
        minAgeSliderText.text = ""
        maxAgeSliderText.text = ""
        minWeightSliderText.text = ""
        maxWeightSliderText.text = ""
        minBPMTextField.text = ""
        maxBPMTextField.text = ""
        durationTextField.text = ""
        minSleepingHoursTextField.text = ""
        maxSleepingHoursTextField.text = ""        
        heartRateSwitch.setOn(false, animated: true)
        activeEnergyBurnedSwitch.setOn(false, animated: true)
        bloodPressureSwitch.setOn(false, animated: true)
        stepsSwitch.setOn(false, animated: true)
        sleepingHoursSwitch.setOn(false, animated: true)
        standingHoursSwitch.setOn(false, animated: true)
        heightSwitch.setOn(false, animated: true)
        weightSwitch.setOn(false, animated: true)
        subscriptionSwitch.setOn(false, animated: true)
    }
    
    // Return a list of requested datatypes
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
    
    // Add upper and lower bound for each search parameter
    func getBounds() -> [D4HBound]{
        var bounds: [D4HBound] = []
        
        let ageBound = D4HBound(upperbound: Double(Int(maxAgeSlider.value)), lowerbound: Double(Int(minAgeSlider.value)))
        bounds.append(ageBound)
        
        let weightBound = D4HBound(upperbound: Double(Int(maxWeightSlider.value)), lowerbound: Double(Int(minWeightSlider.value)))
        bounds.append(weightBound)
        
        let heartRateBound = D4HBound(upperbound: Double(Int(minBPMTextField.text!) ?? 0) , lowerbound: Double(Int(maxBPMTextField.text!) ?? 1000) )
        bounds.append(heartRateBound)
        
        let sleepingHoursBound = D4HBound(upperbound: Double(Int(minSleepingHoursTextField.text!) ?? 0), lowerbound: Double(Int(minSleepingHoursTextField.text!) ?? 1000))
        bounds.append(sleepingHoursBound)
        
        return bounds
    }
    
    @IBAction func minAgeSliderValueChanged(_ sender: UISlider) {
        let currentValue: Int = Int(sender.value)
        self.minAgeSliderText.text = "\(currentValue) yo"
    }
    
    @IBAction func maxAgeSliderValueChanged(_ sender: UISlider) {
        let currentValue: Int = Int(sender.value)
        self.maxAgeSliderText.text = "\(currentValue) yo"
    }
    
    @IBAction func minWeightSliderValueChanged(_ sender: UISlider) {
        let currentValue: Int = Int(sender.value)
        self.minWeightSliderText.text = "\(currentValue) kg"
    }
    
    @IBAction func maxWeightSliderValueChanged(_ sender: UISlider) {
        let currentValue: Int = Int(sender.value)
        self.maxWeightSliderText.text = "\(currentValue) kg"
    }
}
