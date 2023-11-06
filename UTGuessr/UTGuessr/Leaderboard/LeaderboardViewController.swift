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
    
    let userDefaults = UserDefaults.standard
    let db = Firestore.firestore()
    
    @IBOutlet weak var leaderboardTableView: UITableView!
    let leaderboardTableCellIdentifier = "LeaderboardTableCell"
    
    var leaderboardTableCells:[[String]] = []
    
    override func viewWillAppear(_ animated: Bool) {
        if userDefaults.bool(forKey: "UTGuesserDarkMode") {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
        
        populateTop25Users()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        leaderboardTableView.delegate = self
        leaderboardTableView.dataSource = self
        leaderboardTableView.backgroundColor = UIColor(red: CGFloat(252/255.0), green: CGFloat(234/255.0), blue: CGFloat(213/255.0), alpha: CGFloat(1))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardTableCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderboardTableView.dequeueReusableCell(withIdentifier: leaderboardTableCellIdentifier, for: indexPath as IndexPath) as! LeaderboardTableViewCell
        
        // Set the text in the textLable of the Cell to the team at the corresponding index to the row number
        let row = indexPath.row
        cell.placeLabel.text = "\(row + 1)"
        cell.usernameLabel.text = leaderboardTableCells[row][0]
        cell.highScoreLabel.text = leaderboardTableCells[row][1]
        
        if (row % 2 == 1) {
            cell.backgroundColor = UIColor(red: CGFloat(252/255.0), green: CGFloat(234/255.0), blue: CGFloat(213/255.0), alpha: CGFloat(1))
        } else {
            cell.backgroundColor = .white
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        leaderboardTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func populateTop25Users() {
        print("************** GETTING TOP 25 **************")
        let usersRef = self.db.collection("users")
        leaderboardTableCells = []
        usersRef.order(by: "high_score", descending: true).limit(to: 25).getDocuments() {
            (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let username = document.data()["username"] as! String
                    let highScore = document.data()["high_score"] as! Int
                    self.leaderboardTableCells.append([username, String(highScore)])
                }
                self.leaderboardTableView.reloadData()
            }
        }
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
