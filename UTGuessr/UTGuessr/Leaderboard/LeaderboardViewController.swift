//
//  LeaderboardViewController.swift
//  UTGuessr
//
//  Created by Megan Sickler on 11/5/23.
//

import UIKit

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var leaderboardTableView: UITableView!
    let leaderboardTableCellIdentifier = "LeaderboardTableCell"
    
    var leaderboardTableCells:[[String]] = []
    
    override func viewWillAppear(_ animated: Bool) {
        if userDefaults.bool(forKey: "UTGuesserDarkMode") {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        leaderboardTableView.delegate = self
        leaderboardTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = LeaderboardTableViewCell()
        headerCell.placeLabel.text = "Place"
        headerCell.usernameLabel.text = "Username"
        headerCell.highScoreLabel.text = "High Score"
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardTableCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderboardTableView.dequeueReusableCell(withIdentifier: leaderboardTableCellIdentifier, for: indexPath as IndexPath) as! LeaderboardTableViewCell
        
        // Set the text in the textLable of the Cell to the team at the corresponding index to the row number
        let row = indexPath.row
        cell.placeLabel.text = "\(row + 1)"
        cell.usernameLabel.text = "" // TODO: replace
        cell.highScoreLabel.text = ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        leaderboardTableView.deselectRow(at: indexPath, animated: true)
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == teamSegueIdentifier,
//           let destination = segue.destination as? TeamViewController,
//           let teamIndex = tableView.indexPathForSelectedRow?.row {
//            destination.teamName = teams[teamIndex]
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
