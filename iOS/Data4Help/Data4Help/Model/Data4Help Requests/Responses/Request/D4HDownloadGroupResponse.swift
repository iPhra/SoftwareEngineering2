//
//  D4HDownloadGroupResponse.swift
//  Data4Help
//
//  Created by Luca Molteni on 20/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import SwiftyJSON

class D4HDownloadGroupResponse: D4HResponse {
    
    // MARK: - Properties
    
    let path: URL?
    
    // MARK: - initialization
    
    init(fromJson json: JSON) {
        let fileName = "Tasks.csv"
        self.path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        // Document structure
        var csvText = "UserID,DataType,Value,Timestamp\n"
        
        // Loop through data
        let dataJSON = json["data"].arrayValue
        for anonUserJSON in dataJSON {
            let userID = anonUserJSON["userid"].stringValue
            let userDataJSON = anonUserJSON["data"].arrayValue
            for userDataJSON in userDataJSON {
                let datatype = userDataJSON["type"].stringValue
                let valuesJSON = userDataJSON["values"].arrayValue
                for valueJSON in valuesJSON {
                    let value = valueJSON["value"].stringValue
                    let timestamp = valueJSON["timest"].stringValue
                    
                    // Create a new line of data for for each entry and add it to the csv file.
                    let newLine = "\(userID),\(datatype),\(value),\(timestamp)\n"
                    csvText.append(newLine)
                }
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
