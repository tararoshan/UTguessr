//
//  CountdownViewController.swift
//  UTGuessr
//
//  Created by Alex Lu on 10/5/23.
//

import UIKit
import AVFAudio

class CountdownViewController: UIViewController {
    
    var sysTimer = Timer()
    let segueToGameIdentifier = "CountdownToGame"
    
    @IBOutlet weak var timer: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    let userDefaults = UserDefaults.standard
    var audioPlayer:AVAudioPlayer?
    
    override func viewWillAppear(_ animated: Bool) {
        // Handle UI mode
        let displaySetting = userDefaults.integer(forKey: "UTGuesserDarkMode")
        if displaySetting == displayTypeEnum.system.rawValue {
            overrideUserInterfaceStyle = .unspecified
        } else if displaySetting == displayTypeEnum.dark.rawValue {
            overrideUserInterfaceStyle = .dark
        } else if displaySetting == displayTypeEnum.light.rawValue{
            overrideUserInterfaceStyle = .light
        }
        timer.text = "3"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        // Handle the sound effects
        if !self.userDefaults.bool(forKey: "UTGuesserSoundOff") {
            let path = Bundle.main.path(forResource: "countdown.wav", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer!.play()
            } catch {
                print("Couldn't load sound effect.")
            }
        }
        
        sysTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop counting down
        sysTimer.invalidate()
    }
    
    @objc func countDown(){
        timer.text = String(Int(timer.text!)! - 1)
        if Int(timer.text!)! <= 0 {
            performSegue(withIdentifier: segueToGameIdentifier, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let gameViewController = segue.destination as? GameViewController {
            gameViewController.modalPresentationStyle = .fullScreen
        }
    }
}
