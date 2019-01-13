//
//  TPRequestsController.swift
//  Data4Help
//
//  Created by Virginia Negri on 15/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire

class TPRequestsController: UIViewController, UITableViewDelegate, UITableViewDataSource, RequestCellDelegate, UISearchBarDelegate {

    // MARK: Properties
    
    var singleRequests: [TPSingleRequest] = []
    var groupRequests: [TPGroupRequest] = []
    var filteredSingleRequests: [TPSingleRequest] = []
    var filteredGroupRequests: [TPGroupRequest] = []
    
    var searchActive : Bool = false
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red: 233/255, green: 105/255, blue: 103/255, alpha: 1)
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        return refreshControl
    }()
    
    // MARK: Outlets
    
    @IBOutlet var requestsTableView: UITableView!
    @IBOutlet weak var requestsResearchBar: UISearchBar!
    
    // Mark: Initializers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide keyboard when tap out
        self.hideKeyboardWhenTappedAround()
        
        self.requestsTableView.dataSource = self
        self.requestsTableView.delegate = self
        self.requestsResearchBar.delegate = self
        
        loadData()
        
        requestsTableView.refreshControl = self.refresher
        
        // Just register the whole table view for force touch
        // no need to register the individual cells!
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self as! UIViewControllerPreviewingDelegate, sourceView: requestsTableView)
        }
    }
    
    // Mark: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filteredSingleRequests.count + filteredGroupRequests.count
        }
        return singleRequests.count + groupRequests.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(searchActive){
            if (indexPath.row < filteredSingleRequests.count) {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "TPRequestCell", for: indexPath) as? TPRequestCell  else {
                    fatalError("The dequeued cell is not an instance of TPRequestCell.")
                }
                let request = filteredSingleRequests[indexPath.row]
                cell.initRequest(reqid: request.reqid, user: request.full_name, types: request.types, subscribing: request.subscribing, duration: Float(request.duration ?? 0), date: request.date, expired: request.expired)
                cell.delegate = self
                return cell
            }
            else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "TPGroupRequestCell", for: indexPath) as? TPGroupRequestCell  else {
                    fatalError("The dequeued cell is not an instance of TPGroupRequestCell.")
                }
                // TODO implement this part
                let request = filteredGroupRequests[indexPath.row - filteredSingleRequests.count]
                cell.initRequest(reqid: request.reqid, groupname: ("Group " + String(request.reqid)), types: request.types, filters: request.parameters, subscribing: request.subscribing, duration: Float(request.duration ?? 0), date: request.date, expired: request.expired)
                cell.delegate = self
                return cell
            }
        } else {
            if (indexPath.row < singleRequests.count) {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "TPRequestCell", for: indexPath) as? TPRequestCell  else {
                    fatalError("The dequeued cell is not an instance of TPRequestCell.")
                }
                let request = singleRequests[indexPath.row]
                cell.initRequest(reqid: request.reqid, user: request.full_name, types: request.types, subscribing: request.subscribing, duration: Float(request.duration ?? 0), date: request.date, expired: request.expired)
                cell.delegate = self
                return cell
            }
            else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "TPGroupRequestCell", for: indexPath) as? TPGroupRequestCell  else {
                    fatalError("The dequeued cell is not an instance of TPGroupRequestCell.")
                }
                // TODO implement this part
                let request = groupRequests[indexPath.row - singleRequests.count]
                cell.initRequest(reqid: request.reqid, groupname: ("Group " + String(request.reqid)), types: request.types, filters: request.parameters, subscribing: request.subscribing, duration: Float(request.duration ?? 0), date: request.date, expired: request.expired)
                cell.delegate = self
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 100.0;//Your custom row height
    }
    
    // MARK: Private implementation

    @objc
    func loadData() {
        // API call to retrieve requests
        NetworkManager.sharedInstance.sendGetRequest(input: D4HThirdPartyListRequest(authToken: Properties.authToken), endpoint: D4HEndpoint.requestListThirdParty, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres = D4HThirdPartyListResponse(fromJson: response!)
                self.singleRequests = myres.singleRequests
                self.groupRequests = myres.groupRequests
                // Debug
                print(self.singleRequests.count)
                self.requestsTableView.reloadData()
            }
            else if let error = error {
                print(error)
            }
        }
        
        let deadline = DispatchTime.now() + .milliseconds(700) //put in completion block??
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    func saveCSVgroup(reqid: String) {
        // API call to download request data
        NetworkManager.sharedInstance.sendPostRequest(input: D4HDownloadGroupRequest(reqID: reqid), endpoint: D4HEndpoint.downloadGroupRequest, headers: Properties.auth()) { (response, error) in
         if response != nil {
         let myres = D4HDownloadGroupResponse(fromJson: response!)
            // Show download action
            let vc = UIActivityViewController(activityItems: [myres.path], applicationActivities: [])
             /*vc.excludedActivityTypes = [
             UIActivity.ActivityType.assignToContact,
             UIActivity.ActivityType.saveToCameraRoll,
             UIActivity.ActivityType.postToFlickr,
             UIActivity.ActivityType.postToVimeo,
             UIActivity.ActivityType.postToTencentWeibo,
             UIActivity.ActivityType.postToTwitter,
             UIActivity.ActivityType.postToFacebook,
             UIActivity.ActivityType.openInIBooks
             ]*/
            self.present(vc, animated: true, completion: nil)
         }
         else if let error = error {
            print(error)
            }
         }
    }
    
    func saveCSVsingle(reqid: String) {
        // API call to download request data
        NetworkManager.sharedInstance.sendPostRequest(input: D4HDownloadSingleRequest(reqID: reqid), endpoint: D4HEndpoint.downloadSingleRequest, headers: Properties.auth()) { (response, error) in
         if response != nil {
         let myres = D4HDownloadSingleResponse(fromJson: response!)
         // Show download action
         let vc = UIActivityViewController(activityItems: [myres.path], applicationActivities: [])
         /*vc.excludedActivityTypes = [
         UIActivity.ActivityType.assignToContact,
         UIActivity.ActivityType.saveToCameraRoll,
         UIActivity.ActivityType.postToFlickr,
         UIActivity.ActivityType.postToVimeo,
         UIActivity.ActivityType.postToTencentWeibo,
         UIActivity.ActivityType.postToTwitter,
         UIActivity.ActivityType.postToFacebook,
         UIActivity.ActivityType.openInIBooks
         ]*/
         self.present(vc, animated: true, completion: nil)
         }
         else if let error = error {
         print(error)
         }
         }

    }
    
    // MARK: SearchBar management
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredSingleRequests = singleRequests.filter({ (req) -> Bool in
            return req.full_name.range(of: searchText, options: .caseInsensitive) != nil
        })
        filteredGroupRequests = groupRequests.filter({ (req) -> Bool in
            return ("Group "+String(req.reqid)).range(of: searchText, options: .caseInsensitive) != nil
        })
        if(filteredSingleRequests.count + filteredGroupRequests.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.requestsTableView.reloadData()
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: Force Touch on Table View

extension TPRequestsController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = requestsTableView.indexPathForRow(at: location) {
            
            if let cell = requestsTableView.cellForRow(at: indexPath) as? TPRequestCell {
                let sb = UIStoryboard(name: "ThirdParty", bundle: nil)
                let popup = sb.instantiateViewController(withIdentifier: "PopupRequestViewController") as! PopupRequestViewController
                popup.initPopup(title: cell.singleUserLabel.text, datatypes: cell.dataTypesLabel.text, subscribing: cell.subscribing, date: cell.dateLabel.text, duration: cell.duration, expired: cell.expired)
                return popup
            }
            
            let groupCell = requestsTableView.cellForRow(at: indexPath) as! TPGroupRequestCell
            let sb = UIStoryboard(name: "ThirdParty", bundle: nil)
            let popup = sb.instantiateViewController(withIdentifier: "PopupRequestViewController") as! PopupRequestViewController
            popup.initPopup(title: groupCell.groupNameLabel.text, datatypes: groupCell.datatypesLabel.text, subscribing: groupCell.subscribing, date: groupCell.dateLabel.text, duration: groupCell.duration, expired: groupCell.expired)
            popup.initFilters(healthparameters: groupCell.filters ?? [])
            return popup
            
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    
    func touchedView(view: UIView, location: CGPoint) -> Bool {
        let locationInView = view.convert(location, from: requestsTableView)
        return view.bounds.contains(locationInView)
    }
    
}
