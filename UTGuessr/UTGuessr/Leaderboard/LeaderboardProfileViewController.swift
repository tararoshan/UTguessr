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
    
    var userEmail:String!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set rounded borders (make into a circle)
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2

        // TODO: unhide when competitive is implemented
        competitiveGamesPlayedLabel.text = "Unavailable"
        gamesWonLabel.isHidden = true
        
        let userDocRef = self.db.collection("users").document(userEmail)
        userDocRef.getDocument {
            (document, error) in
            if let document = document, document.exists {
                let averageScore = document.data()!["average_score"]! as! Float
                let highScore = document.data()!["high_score"]! as! Int
                let gamesPlayed = document.data()!["games_played"]! as! Int
                
                let username = document.data()!["username"]! as! String
                let profileImage = document.data()!["profile_image"] as? UIImage
                
                if profileImage != nil {
                    // TODO: put profile image
                    print("PROFILE IMAGE NOT NULL")
                    print(profileImage)
                } else {
                    self.profileImage.image = UIImage(named: "defaultProfileImage")
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
