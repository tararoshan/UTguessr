//
//  SettingsViewController.swift
//  UTGuessr
//
//  Created by Megan Sickler on 11/1/23.
//

import UIKit

// Enum for display setting
enum displayTypeEnum: Int {
    case system = 0
    case light = 1
    case dark = 2
}

// Settings page
class SettingsViewController: UIViewController {

    // Two segmented controls
    @IBOutlet weak var displayControl: UISegmentedControl!
    @IBOutlet weak var soundControl: UISegmentedControl!

    // Info for sound and display settings
    let userDefaults = UserDefaults.standard

    // Setting display based on settings and initializing segmented controls
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
    }

    // Handling change in display settings
    @IBAction func displayControlChanged(_ sender: Any) {
        userDefaults.set(displayControl.selectedSegmentIndex, forKey: "UTGuesserDarkMode")

        let displaySetting = userDefaults.integer(forKey: "UTGuesserDarkMode")
        if displaySetting == displayTypeEnum.system.rawValue {
            overrideUserInterfaceStyle = .unspecified
        } else if displaySetting == displayTypeEnum.dark.rawValue {
            overrideUserInterfaceStyle = .dark
        } else if displaySetting == displayTypeEnum.light.rawValue {
            overrideUserInterfaceStyle = .light
        }
    }

    // Handling change in sound settings
    @IBAction func soundControlChanged(_ sender: Any) {
        userDefaults.set(soundControl.selectedSegmentIndex, forKey: "UTGuesserSoundOff")
    }
}
