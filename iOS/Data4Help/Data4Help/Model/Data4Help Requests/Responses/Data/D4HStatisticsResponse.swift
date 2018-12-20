//
//  D4HStatisticsResponse.swift
//  Data4Help
//
//  Created by Luca Molteni on 20/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import SwiftyJSON

class D4HStatisticsResponse: D4HResponse {
    
    // MARK: - Properties
    
    var statistics: [D4HStatistic]
    
    // MARK: - initialization
    
    init(statistics: [D4HStatistic]) {
        self.statistics = statistics
    }
    
    init(fromJson json: JSON) {
        let dataJSON = json["data"].arrayValue
        self.statistics = []
        for datatypeJSON in dataJSON {
            self.statistics.append(D4HStatistic(fromJson: datatypeJSON))
        }
    }
    
}

