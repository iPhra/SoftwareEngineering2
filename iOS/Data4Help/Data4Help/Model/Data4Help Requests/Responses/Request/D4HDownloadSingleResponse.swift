//
//  D4HDownloadSingleResponse.swift
//  Data4Help
//
//  Created by Luca Molteni on 20/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import SwiftyJSON

class D4HDownloadSingleResponse: D4HResponse {
    
    // MARK: - Properties
    
    // MARK: - initialization
    
    init(fromJson json: JSON) {
        let fileName = "SingleRequest.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        // Document structure
        var csvText = "DataType,Value,Timestamp\n"
        
        // Loop through data
        let dataJSON = json["data"].arrayValue
        for datatypeJSON in dataJSON {
            let datatype = datatypeJSON["type"].stringValue
            let observationsJSON = datatypeJSON["observations"].arrayValue
            for observationJSON in observationsJSON {
                let value = observationJSON["value"].stringValue
                let timestamp = observationJSON["timest"].stringValue
                
                // Create a new line of data for for each entry and add it to the csv file.
                let newLine = "\(datatype),\(value),\(timestamp)\n"
                csvText.append(newLine)
            }
        }
        
        // Write file in the specified path
        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            
            print("csv saved")
            print(csvText)
            // Show download action
            /*let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
             vc.excludedActivityTypes = [
             UIActivity.ActivityType.assignToContact,
             UIActivity.ActivityType.saveToCameraRoll,
             UIActivity.ActivityType.postToFlickr,
             UIActivity.ActivityType.postToVimeo,
             UIActivity.ActivityType.postToTencentWeibo,
             UIActivity.ActivityType.postToTwitter,
             UIActivity.ActivityType.postToFacebook,
             UIActivity.ActivityType.openInIBooks
             ]
             presentViewController(vc, animated: true, completion: nil)*/
            
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
    }
    
}
