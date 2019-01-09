//
//  AutomatedSOSManager.swift
//  Data4Help
//
//  Created by Virginia Negri on 22/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import Foundation
import UIKit

class BloodPressure {
    var systolic: Double?
    var diastolyc: Double?
    
    init(systolic: Double, diastolyc: Double){
        self.systolic = systolic
        self.diastolyc = diastolyc
    }
    
    func isToppedBy(systolic: Double, diastolyc: Double) -> Bool{
        if((self.systolic?.isLessThanOrEqualTo(systolic))! && (self.diastolyc?.isLessThanOrEqualTo(diastolyc))!){
            return true
        }
        else{
            return false
        }
    }
    func isLoweredBy(systolic: Double, diastolyc: Double) -> Bool {
        if(systolic.isLessThanOrEqualTo(self.systolic!) && diastolyc.isLessThanOrEqualTo(self.diastolyc!)){
            return true
        }
        else{
            return false
        }
    }
}

class AutomatedSOSManager {
    
    // MARK: Properties
    
    let bloodPressureUpperBound: BloodPressure = BloodPressure(systolic: 140.0,diastolyc: 90.0) //STAGE 2 HYPERTENSION NYHA
    let bloodPressureLowerBound: BloodPressure = BloodPressure(systolic: 90.0,diastolyc: 60.0) //HYPOTENSION NYHA
    let heartRateUpperBound: Double = 150.0
    let heartRateLowerBound: Double = 45.0
    
    var lastHeartRateSample:Double?
    var lastHeartRateSampleTimestamp:String?
    var lastBloodPressureSample:BloodPressure?
    var lastBloodPressureTimestamp:String?
    
    // MARK: Functions
    
    func callAmbulance(){
        if let url = URL(string: "tel://\(112)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func checkHeartRate(heartRate: Double, timestamp: String){
        self.lastHeartRateSample = heartRate
        if(heartRate<heartRateLowerBound || heartRate>heartRateUpperBound){
            callAmbulance()
        }
        else{
            return
        }
    }
    
    func checkBloodPressure(systolic: Double, diastolyc: Double, timestamp: String){
        self.lastBloodPressureSample = BloodPressure(systolic: systolic, diastolyc: diastolyc)
        self.lastBloodPressureTimestamp = timestamp
        if(self.bloodPressureUpperBound.isToppedBy(systolic: systolic, diastolyc: diastolyc) || self.bloodPressureLowerBound.isLoweredBy(systolic: systolic, diastolyc: diastolyc)){
            callAmbulance()
        }
    }
    
}
