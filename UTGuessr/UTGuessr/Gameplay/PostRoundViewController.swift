//
//  PostRoundViewController.swift
//  UTGuessr
//
//  Created by Teresa Luo on 10/12/23.
//

import UIKit

class PostRoundViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    var score:String = ""
    
    var game:Game!
    @IBOutlet weak var nextRoundButton: UIButton!
    @IBOutlet weak var finishGameButton: UIButton!
    
    let userDefaults = UserDefaults.standard
    
    let segueToPostGameIdentifier = "PostRoundToPostGame"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if userDefaults.bool(forKey: "UTGuesserDarkMode") {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        self.scoreLabel.text = score
        
        if self.game!.isOver() {
            // Hide the Next Round Button and show the Finish Game Button
            print("disabling next round")
            self.nextRoundButton.isHidden = true
            self.finishGameButton.isHidden = false
        } else {
            // The game is not over -- hide the Finish Game Button and show the Next Round Button
            self.nextRoundButton.isHidden = false
            self.finishGameButton.isHidden = true
        }
    }
    
    @IBAction func nextRoundPressed(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func finishGamePressed(_ sender: Any) {
        performSegue(withIdentifier: segueToPostGameIdentifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == segueToPostGameIdentifier),
           let postGameVC = segue.destination as? PostGameViewController {
            postGameVC.game = self.game
        }
    }
}
