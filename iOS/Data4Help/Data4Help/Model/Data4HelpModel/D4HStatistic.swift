//
//  D4HStatistic.swift
//  Data4Help
//
//  Created by Luca Molteni on 20/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class D4HStatistic {
    
    // MARK: parameters
    
    let type: dataType
    var observations: [D4HObservation]
    
    // MARK: Initialisators
    
    init(type: dataType, observations: [D4HObservation]) {
        self.type = type
        self.observations = observations
    }
    
    init(fromJson json: JSON) {
        let type = json["type"].stringValue
        self.type = dataType(rawValue: type)!
        self.observations = []
        let observationsJSON = json["observations"].arrayValue
        for observationJSON in observationsJSON {
            self.observations.append(D4HObservation(fromJson: observationJSON))
        }
    }
}

