//
//  SettingsViewController.swift
//  UTGuessr
//
//  Created by Megan Sickler on 11/1/23.
//

import UIKit

enum displayTypeEnum: Int {
case system = 0, light = 1, dark = 2
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var displayControl: UISegmentedControl!
    @IBOutlet weak var soundControl: UISegmentedControl!
    
    let userDefaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkText]
        displayControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        soundControl.setTitleTextAttributes(titleTextAttributes, for: .normal)

        let displaySetting = userDefaults.integer(forKey: "UTGuesserDarkMode")
        displayControl.selectedSegmentIndex = displaySetting
        if displaySetting == displayTypeEnum.system.rawValue {
            overrideUserInterfaceStyle = .unspecified
        } else if displaySetting == displayTypeEnum.dark.rawValue {
            overrideUserInterfaceStyle = .dark
        } else if displaySetting == displayTypeEnum.light.rawValue {
            overrideUserInterfaceStyle = .light
        }
        
        if userDefaults.bool(forKey: "UTGuesserSoundOff") {
            soundControl.selectedSegmentIndex = 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func displayControlChanged(_ sender: Any) {
        userDefaults.set(displayControl.selectedSegmentIndex, forKey: "UTGuesserDarkMode")
        
        let displaySetting = userDefaults.integer(forKey: "UTGuesserDarkMode")
        if displaySetting == displayTypeEnum.system.rawValue {
            overrideUserInterfaceStyle = .unspecified
        } else if displaySetting == displayTypeEnum.dark.rawValue {
            overrideUserInterfaceStyle = .dark
        } else if displaySetting == displayTypeEnum.light.rawValue{
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
