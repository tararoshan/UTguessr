//
//  PostGameViewController.swift
//  UTGuessr
//
//  Created by Teresa Luo on 10/12/23.
//

import UIKit

class PostGameViewController: UIViewController {
    
    let segueToCountdownIdentifier = "PostGameToCountdown"
    
    @IBOutlet weak var round1ScoreLabel: UILabel!
    @IBOutlet weak var round2ScoreLabel: UILabel!
    @IBOutlet weak var round3ScoreLabel: UILabel!
    @IBOutlet weak var round4ScoreLabel: UILabel!
    @IBOutlet weak var round5ScoreLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    var game:Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.scoreLabel.text = String(self.game!.roundScores.reduce(0, +))
        self.round1ScoreLabel.text = String(self.game!.roundScores[0])
        self.round2ScoreLabel.text = String(self.game!.roundScores[1])
        self.round3ScoreLabel.text = String(self.game!.roundScores[2])
        self.round4ScoreLabel.text = String(self.game!.roundScores[3])
        self.round5ScoreLabel.text = String(self.game!.roundScores[4])
    }
    
    @IBAction func playAgainPressed(_ sender: Any) {
        // TODO: add more logic for new game
        performSegue(withIdentifier: segueToCountdownIdentifier, sender: nil)
    }
    
    // Set up segues after each game
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Let the tab controller know to present the game page
        if let tabBarController = segue.destination as? UITabBarController {
            if segue.identifier == "PostGameToCountdown" {
                tabBarController.selectedIndex = 0
            }
        }
    }
    
}
