//
//  LeaderboardProfileViewController.swift
//  UTGuessr
//
//  Created by Teresa Luo on 11/6/23.
//

import UIKit
import FirebaseFirestore

class LeaderboardProfileViewController: UIViewController {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var individualGamesPlayedLabel: UILabel!
    @IBOutlet weak var averageScoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    @IBOutlet weak var competitiveGamesPlayedLabel: UILabel!
    @IBOutlet weak var gamesWonLabel: UILabel!
    
    @IBOutlet weak var contributorLabel: UILabel!
    
    var userEmail:String!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set rounded borders (make into a circle)
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2

        // TODO: unhide when competitive is implemented
        competitiveGamesPlayedLabel.text = "Unavailable"
        gamesWonLabel.isHidden = true
        
        // Hide the contributor label until we load data
        contributorLabel.isHidden = true
        
        let userDocRef = self.db.collection("users").document(userEmail)
        userDocRef.getDocument {
            (document, error) in
            if let document = document, document.exists {
                let averageScore = document.data()!["average_score"]! as! Float
                let highScore = document.data()!["high_score"]! as! Int
                let gamesPlayed = document.data()!["games_played"]! as! Int
                
                let username = document.data()!["username"]! as! String
                let profileImageData = document.data()!["profile_image"] as? Data
                
                let numImagesUploaded = document.data()!["images_uploaded"] as! Int
                
                if profileImageData != nil {
                    self.profileImage.image = UIImage(data: profileImageData!)
                    self.profileImage.contentMode = .scaleAspectFill
                } else {
                    self.profileImage.image = UIImage(named: "defaultProfileImage")
                }
                
                if numImagesUploaded >= 25 {
                    // Gold Contributor
                    self.contributorLabel.text = "Gold Contributor"
                    self.contributorLabel.textColor = UIColor(red: 228/255.0, green: 202/255.0, blue: 106/255.0, alpha: 1)
                    self.contributorLabel.isHidden = false
                } else if numImagesUploaded >= 10 {
                    // Silver Contributor
                    self.contributorLabel.text = "Silver Contributor"
                    self.contributorLabel.textColor = .lightGray
                    self.contributorLabel.isHidden = false
                }
                
                self.usernameLabel.text = username
                self.individualGamesPlayedLabel.text = "Games Played: \(gamesPlayed)"
                self.averageScoreLabel.text = "Average Score: \(Int(averageScore))"
                self.highScoreLabel.text = "High Score: \(highScore)"
            } else {
                print("Firebase Firestore: Can't find user data")
            }
        }
    }
}
