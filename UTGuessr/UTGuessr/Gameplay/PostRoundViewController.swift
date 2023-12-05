//
//  PostRoundViewController.swift
//  UTGuessr
//
//  Created by Teresa Luo on 10/12/23.
//

import UIKit
import AVFAudio

class PostRoundViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    var score:String = ""
    
    var game:Game!
    @IBOutlet weak var nextRoundButton: UIButton!
    @IBOutlet weak var finishGameButton: UIButton!
    
    // Info for sound and display settings
    let userDefaults = UserDefaults.standard
    var audioPlayer:AVAudioPlayer?
    
    let segueToPostGameIdentifier = "PostRoundToPostGame"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setting display based on settings
        let displaySetting = userDefaults.integer(forKey: "UTGuesserDarkMode")
        if displaySetting == displayTypeEnum.system.rawValue {
            overrideUserInterfaceStyle = .unspecified
        } else if displaySetting == displayTypeEnum.dark.rawValue {
            overrideUserInterfaceStyle = .dark
        } else if displaySetting == displayTypeEnum.light.rawValue{
            overrideUserInterfaceStyle = .light
        }
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        self.scoreLabel.text = score
        
        if self.game!.isOver() {
            // Hide the Next Round Button and show the Finish Game Button
            self.nextRoundButton.isHidden = true
            self.finishGameButton.isHidden = false
        } else {
            // The game is not over -- hide the Finish Game Button and show the Next Round Button
            self.nextRoundButton.isHidden = false
            self.finishGameButton.isHidden = true
        }
    }
    
    @IBAction func nextRoundPressed(_ sender: Any) {
        // Button press sound effect
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
        
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func finishGamePressed(_ sender: Any) {
        // Button press sound effect
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
        
        // Write the game information to the database
        self.game.finishGame()
        performSegue(withIdentifier: segueToPostGameIdentifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == segueToPostGameIdentifier),
           let postGameVC = segue.destination as? PostGameViewController {
            postGameVC.game = self.game
        }
    }
}
