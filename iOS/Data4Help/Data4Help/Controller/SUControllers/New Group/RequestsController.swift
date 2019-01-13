//
//  RequestsController.swift
//  Data4Help
//
//  Created by Virginia Negri on 15/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Alamofire


class RequestsController: UIViewController, UITableViewDelegate, UITableViewDataSource, SUCellDelegate, UISearchBarDelegate {
    
    // MARK: Properties
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red: 233/255, green: 105/255, blue: 103/255, alpha: 1)
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        return refreshControl
    }()
    
    enum TableSection: Int {
        case accepted = 0, pending, refused, total
    }
    var requests: [SUSingleRequest] = []
    var data = [TableSection: [SUSingleRequest]]()  // Data variable to track sorted data.
    var filtered = [TableSection: [SUSingleRequest]]() // Filtered data used by SearchBar
    
    let SectionHeaderHeight: CGFloat = 30
    var searchActive : Bool = false
    
    // MARK: Outlets
    
    @IBOutlet var requestsTableView: UITableView!
    @IBOutlet weak var requestsResearchBar: UISearchBar!
    
    // MARK: Initializers
    
    override func viewWillAppear(_ animated: Bool) {
        print("View will appear")
        loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("vIew loaded")
        
        // Hide keyboard when tap out
        self.hideKeyboardWhenTappedAround()
        
        self.requestsTableView.delegate = self
        self.requestsTableView.dataSource = self
        self.requestsResearchBar.delegate = self
    
        // Load requests from backend
        loadData()
        
        requestsTableView.refreshControl = self.refresher
    }
    
    // Mark: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableSection.total.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            if let tableSection = TableSection(rawValue: section), let filteredReqData = filtered[tableSection] {
                return filteredReqData.count
            }
        }
        if let tableSection = TableSection(rawValue: section), let reqData = data[tableSection] {
            return reqData.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: SectionHeaderHeight))
        view.backgroundColor = UIColor(red: 235.0/255.0, green: 104.0/255.0, blue: 100.0/255.0, alpha: 1)
        let label = UILabel(frame: CGRect(x: 15, y: -5, width: tableView.bounds.width - 30, height: SectionHeaderHeight))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.white
        if let tableSection = TableSection(rawValue: section) {
            switch tableSection {
            case .accepted:
                label.text = "Accepted Requests"
            case .pending:
                label.text = "Pending Requests"
            case .refused:
                label.text = "Refused Requests"
            default:
                label.text = ""
            }
        }
        view.addSubview(label)
        return view
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SURequestCell", for: indexPath) as? SURequestCell  else {
            fatalError("The dequeued cell is not an instance of SURequestCell.")
        }
        
        cell.delegate = self
        
        if(searchActive){
            if let tableSection = TableSection(rawValue: indexPath.section), let request = filtered[tableSection]?[indexPath.row] {
                cell.initRequest(reqID: request.reqid, senderID: request.company_name, types: request.types, subscribing: request.subscribing, duration: Float(request.duration ?? 0), expired: request.expired)
                if(tableSection != TableSection(rawValue: 1)) {
                    cell.acceptButton.isHidden = true
                    cell.refuseButton.isHidden = true
                }
            }
        } else {
            if let tableSection = TableSection(rawValue: indexPath.section), let request = data[tableSection]?[indexPath.row] {
                cell.initRequest(reqID: request.reqid, senderID: request.company_name, types: request.types, subscribing: request.subscribing, duration: Float(request.duration ?? 0), expired: request.expired)
                if(tableSection != TableSection(rawValue: 1)) {
                    cell.acceptButton.isHidden = true
                    cell.refuseButton.isHidden = true
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 100.0; // Custom row height
    }
    
    
    // MARK: Private implementation
    
    @objc
    func loadData() {
        // API call to retrieve requests
        
        print("Loading data")
        NetworkManager.sharedInstance.sendGetRequest(input: D4HSingleListRequest(authToken: Properties.authToken), endpoint: D4HEndpoint.requestListSingle, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres = D4HSingleListResponse(fromJson: response!)
                self.requests = myres.requests
                print(self.requests.count)
                self.sortData()
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
    
    // Split retrieved requests between accepted, pending, refused
    func sortData() {
        data[.accepted] = requests.filter({ $0.status == "accepted" })
        data[.pending] = requests.filter({ $0.status == "pending" })
        data[.refused] = requests.filter({ $0.status == "refused" })
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
        
        filtered[.accepted] = requests.filter({ (req) -> Bool in
            return req.company_name.range(of: searchText, options: .caseInsensitive) != nil && req.status == "accepted"
        })
        filtered[.pending] = requests.filter({ (req) -> Bool in
            return req.company_name.range(of: searchText, options: .caseInsensitive) != nil && req.status == "pending"
        })
        filtered[.refused] = requests.filter({ (req) -> Bool in
            return req.company_name.range(of: searchText, options: .caseInsensitive) != nil && req.status == "refused"
        })
        if(filtered[.accepted]?.count == 0 && filtered[.pending]?.count == 0 && filtered[.refused]?.count == 0){
            
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.requestsTableView.reloadData()
    }
    
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
