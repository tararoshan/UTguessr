//
//  MainMenuVC.swift
//  UTGuessr
//
//  Created by tara on 10/16/23.
//

import UIKit
import AVFAudio

class MainMenuVC: UIViewController {
    
    let userDefaults = UserDefaults.standard
    
    var audioPlayer:AVAudioPlayer?
    
    override func viewWillAppear(_ animated: Bool) {
        if userDefaults.bool(forKey: "UTGuesserDarkMode") {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // Get ready for segues (currently just to the main tab controller)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
        
        // Determine if we're segueing to the tab controller & which page to display
        if let tabBarController = segue.destination as? UITabBarController {
            if segue.identifier == "playGameSegue" {
                tabBarController.selectedIndex = 0
            } else if segue.identifier == "uploadLocationSegue" {
                tabBarController.selectedIndex = 1
            } else if segue.identifier == "leaderboardSegue" {
                tabBarController.selectedIndex = 2
            } else if segue.identifier == "profileSegue" {
                tabBarController.selectedIndex = 3
            }
        }
        
    }

}
