//
//  PostGameViewController.swift
//  UTGuessr
//
//  Created by Teresa Luo on 10/12/23.
//

import UIKit
import AVFAudio

class PostGameViewController: UIViewController {
    
    var userDefaults = UserDefaults.standard
    
    var audioPlayer:AVAudioPlayer?
    
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
        
        if !self.userDefaults.bool(forKey: "UTGuesserSoundOff") {
            let path = Bundle.main.path(forResource: "fanfare.mp3", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer!.play()
            } catch {
                print("Couldn't load sound effect.")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if userDefaults.bool(forKey: "UTGuesserDarkMode") {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.scoreLabel.text = String(self.game!.roundScores.reduce(0, +))
        self.round1ScoreLabel.text = String(self.game!.roundScores[0])
        self.round2ScoreLabel.text = String(self.game!.roundScores[1])
        self.round3ScoreLabel.text = String(self.game!.roundScores[2])
        self.round4ScoreLabel.text = String(self.game!.roundScores[3])
        self.round5ScoreLabel.text = String(self.game!.roundScores[4])
    }
    
    @IBAction func playAgainPressed(_ sender: Any) {
        if !self.userDefaults.bool(forKey: "UTGuesserSoundOff") {
            let path = Bundle.main.path(forResource: "click.mp3", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer!.play()
            } catch {
                print("Couldn't load sound effect.")
            }
        }
        
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
