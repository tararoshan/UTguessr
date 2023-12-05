//
//  LeaderboardViewController.swift
//  UTGuessr
//
//  Created by Megan Sickler on 11/5/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Info for display settings
    let userDefaults = UserDefaults.standard

    let db = Firestore.firestore()
    
    @IBOutlet weak var leaderboardTableView: UITableView!
    let leaderboardTableCellIdentifier = "LeaderboardTableCell"
    
    let segueToLeaderboardProfileIdentifier = "LeaderboardToLeaderboardProfile"
    
    override func viewWillAppear(_ animated: Bool) {
        // Setting display based on settings
        let displaySetting = userDefaults.integer(forKey: "UTGuesserDarkMode")
        if displaySetting == displayTypeEnum.system.rawValue {
            overrideUserInterfaceStyle = .unspecified
        } else if displaySetting == displayTypeEnum.dark.rawValue {
            overrideUserInterfaceStyle = .dark
        } else if displaySetting == displayTypeEnum.light.rawValue{
            overrideUserInterfaceStyle = .light
        }

        leaderboardTableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        leaderboardTableView.delegate = self
        leaderboardTableView.dataSource = self
        leaderboardTableView.backgroundColor = UIColor.background
        
        // Start listening to changes in high scores and usernames
        leaderboardManager.listenToHighScores()
        leaderboardManager.listenToUsernames()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardManager.leaderboardEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderboardTableView.dequeueReusableCell(withIdentifier: leaderboardTableCellIdentifier, for: indexPath as IndexPath) as! LeaderboardTableViewCell
        
        // Set the text in the textLable of the Cell to the team at the corresponding index to the row number
        let row = indexPath.row
        cell.placeLabel.text = "\(row + 1)"
        // Cell information is stored by the leaderboardManager
        cell.usernameLabel.text = leaderboardManager.leaderboardEntries[row].username
        cell.highScoreLabel.text = String(leaderboardManager.leaderboardEntries[row].highScore)
        
        if (row % 2 == 1) {
            cell.backgroundColor = UIColor.background
        } else {
            cell.backgroundColor = UIColor.cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Show the users profile
        performSegue(withIdentifier: segueToLeaderboardProfileIdentifier, sender: nil)
        leaderboardTableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueToLeaderboardProfileIdentifier,
           let destination = segue.destination as? LeaderboardProfileViewController,
           let selectedIndex = leaderboardTableView.indexPathForSelectedRow?.row {
            destination.userEmail = leaderboardManager.leaderboardEntries[selectedIndex].userEmail
        }
    }
}
