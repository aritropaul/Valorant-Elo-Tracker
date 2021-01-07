//
//  ViewController.swift
//  ValorantTracker
//
//  Created by Aritro Paul on 05/01/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var rankIcon: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var eloLabel: UILabel!
    
    var refreshControl = UIRefreshControl()
    
    
    var matches: [Match] = [Match]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        
        //MARK:- Initial Setup
        gameNameLabel.text = "Loading your Information"
        rankLabel.text = ""
        rankIcon.image = UIImage()
        eloLabel.text = ""
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        
        refreshControl.beginRefreshing()
        
        //MARK:- Nav Customization
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.isTranslucent = true
        
        //MARK:- Data Fetching
        flow { [self] (matches) in
            self.matches = matches?.filter({ (match) -> Bool in
                return match.competitiveMovement != "MOVEMENT_UNKNOWN"
            }) ?? [Match]()
            let latestMatch = self.matches[0]
            DispatchQueue.main.async {
                gameNameLabel.text = (Riot.user?.acct.gameName ?? "") + "#" + (Riot.user?.acct.tagLine ?? "")
                rankLabel.text = rank[latestMatch.tierAfterUpdate ]
                rankIcon.image = UIImage(named: rank[latestMatch.tierAfterUpdate ] ?? "Unranked")
                eloLabel.text = "\(latestMatch.tierProgressAfterUpdate ) / 100"
                tableView.reloadData()
                refreshControl.endRefreshing()
            }
        }
    }
    
    //MARK:- Fetch Flow
    func flow(completion: @escaping([Match]?)->Void) {
        if username != "" && password != "" {
            Riot.shared.authenticate(username: username, password: password) { (status, error)  in
                if status {
                    Riot.shared.getEntitlementToken { (status) in
                        Riot.shared.getUserInfo { (status) in
                            Riot.shared.getMatchQueue(server: "ap") { (result) in
                                switch result {
                                case .success(let matches) : completion(matches)
                                case .failure(let error) :
                                    DispatchQueue.main.async {
                                        let alert = UIAlertController(title: "Error", message: error.errorDescription, preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                        self.refreshControl.endRefreshing()
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: error?.errorDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        }
        else {
            let alert = UIAlertController(title: "Not Logged In", message: "Please login through Settings First", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    
    
    //MARK:- Refresh Function
    @objc func refresh() {
        if userChanged {
            Riot.session.invalidateAndCancel()
            Riot.session = URLSession(configuration: .default)
            let cookieStore = HTTPCookieStorage.shared
            for cookie in cookieStore.cookies ?? [] {
                cookieStore.deleteCookie(cookie)
            }

            userChanged = false
        }
    
        flow { [self] (matches) in
            self.matches = matches?.filter({ (match) -> Bool in
                return match.competitiveMovement != "MOVEMENT_UNKNOWN"
            }) ?? [Match]()
            let latestMatch = self.matches[0]
            DispatchQueue.main.async {
                gameNameLabel.text = (Riot.user?.acct.gameName ?? "") + "#" + (Riot.user?.acct.tagLine ?? "")
                rankLabel.text = rank[latestMatch.tierAfterUpdate ]
                rankIcon.image = UIImage(named: rank[latestMatch.tierAfterUpdate ] ?? "Unranked")
                eloLabel.text = "\(latestMatch.tierProgressAfterUpdate ) / 100"
                tableView.reloadData()
                refreshControl.endRefreshing()
            }
        }
        
        
    }
    
}


//MARK:- TableView Delegate Functions
extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if matches.count > 3 {
            return 3
        }
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "matchCell") as! MatchTableViewCell
        let match = matches[indexPath.row]
        if match.competitiveMovement == "PROMOTED" {
            cell.pointDiffLabel.text = "\(match.tierProgressAfterUpdate - match.tierProgressBeforeUpdate + 100)"
        }
        else if match.competitiveMovement == "DEMOTED" {
            cell.pointDiffLabel.text = "\(match.tierProgressAfterUpdate - match.tierProgressBeforeUpdate - 100)"
        }
        else {
            cell.pointDiffLabel.text = "\(match.tierProgressAfterUpdate - match.tierProgressBeforeUpdate)"
        }
        
        
        if match.mapID.contains("Duality") {
            cell.mapNameLabel.text = "Bind"
        }
        if match.mapID.contains("Triad") {
            cell.mapNameLabel.text = "Haven"
        }
        if match.mapID.contains("Bonsai") {
            cell.mapNameLabel.text = "Split"
        }
        if match.mapID.contains("Ascent") {
            cell.mapNameLabel.text = "Ascent"
        }
        if match.mapID.contains("Port") {
            cell.mapNameLabel.text = "Icebox"
        }
        let (date, time) = getDateAndTime(millisecs: match.matchStartTime)
        cell.dateLabel.text = date
        cell.timeLabel.text = time
        return cell
    }
    
    func getDateAndTime(millisecs: Int) -> (String, String){
        let date = Date(timeIntervalSince1970: TimeInterval(millisecs/1000))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy,HH:mm"
        let dateString = formatter.string(from: date).components(separatedBy: ",")[0]
        let timeString = formatter.string(from: date).components(separatedBy: ",")[1]
        print((dateString, timeString))
        return (dateString, timeString)
    }
    
    
}
