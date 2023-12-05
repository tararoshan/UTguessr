//
//  MainTabBarVC.swift
//  UTGuessr
//
//  Created by tara on 11/6/23.
//
import UIKit
import AVFAudio

class MainTabBarVC: UITabBarController, UITabBarControllerDelegate {
    
    var audioPlayer: AVAudioPlayer?
    let userDefaults = UserDefaults.standard
    var showingRoundEndedScreen: Bool = false
    var restartGame: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Handle sound effects
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
        
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController) {
            // Currently on the game screen, confirm with user before changing screen
            if self.selectedIndex == 0 && !showingRoundEndedScreen {
                let quitGameAlert = UIAlertController(title: "Leave Game", message: "Are you sure you want to quit?", preferredStyle: .alert)
                
                // Change the background color of the alert to fit the theme
                if let firstSubview = quitGameAlert.view.subviews.first,
                   let alertContentView = firstSubview.subviews.first {
                    let tintColor = UIColor(named: "secondaryHeaderColor")
                    alertContentView.backgroundColor = tintColor
                    alertContentView.layer.cornerRadius = 15
                }
                
                // Quit and restart game
                let quitAction = UIAlertAction(title: "Yes", style: .default) {_ in
                    tabBarController.selectedIndex = index
                    self.restartGame = true
                }
                quitGameAlert.addAction(quitAction)
                
                // Keep playing
                let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel)
                quitGameAlert.addAction(cancelAction)
                
                // Customize the appearance of the alert title
                let titleFont = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Bold", size: 20.0) ?? UIFont.boldSystemFont(ofSize: 20.0)]
                let titleAttrString = NSMutableAttributedString(string: "Leave Game", attributes: titleFont)
                quitGameAlert.setValue(titleAttrString, forKey: "attributedTitle")
                
                // Customize the appearance of the alert message
                let messageFont = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Regular", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)]
                let messageAttrString = NSMutableAttributedString(string: "Are you sure you want to quit?", attributes: messageFont)
                quitGameAlert.setValue(messageAttrString, forKey: "attributedMessage")
                
                // And show the alert
                self.present(quitGameAlert, animated: true)
                // Stop the tab selection from happening, it'll go through if the user confirms
                return false
            }
            
            // If we're going back to the game screen, check if the game is supposed to restart
            if index == 0 && self.restartGame,
               let navController = viewController as? UINavigationController {
                self.restartGame = false
                navController.popToRootViewController(animated: true)
            }
        }
        // Allow the tab selection to happen otherwise
        return true
    }
}
