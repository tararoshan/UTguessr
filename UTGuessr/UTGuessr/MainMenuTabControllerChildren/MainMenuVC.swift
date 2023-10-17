//
//  MainMenuVC.swift
//  UTGuessr
//
//  Created by tara on 10/16/23.
//

import UIKit

class MainMenuVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // Get ready for segues (currently just to the main tab controller)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
