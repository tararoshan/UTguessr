//
//  SettingsViewController.swift
//  UTGuessr
//
//  Created by Megan Sickler on 11/1/23.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var displayControl: UISegmentedControl!
    @IBOutlet weak var soundControl: UISegmentedControl!
    
    let userDefaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkText]
        displayControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        soundControl.setTitleTextAttributes(titleTextAttributes, for: .normal)

        if userDefaults.bool(forKey: "UTGuesserDarkMode") {
            overrideUserInterfaceStyle = .dark
            displayControl.selectedSegmentIndex = 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func displayControlChanged(_ sender: Any) {
        userDefaults.set(displayControl.selectedSegmentIndex, forKey: "UTGuesserDarkMode")
        
        if userDefaults.bool(forKey: "UTGuesserDarkMode") {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }
    
    @IBAction func soundControlChanged(_ sender: Any) {
        userDefaults.set(soundControl.selectedSegmentIndex, forKey: "UTGuesserSoundOff")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
