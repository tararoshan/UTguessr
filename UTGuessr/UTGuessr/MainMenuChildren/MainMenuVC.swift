//
//  MainMenuVC.swift
//  UTGuessr
//
//  Created by tara on 10/16/23.
//

import UIKit
import AVFAudio
import FirebaseAuth
import Firebase

class MainMenuVC: UIViewController {
    
    // Info for sound and display settings
    let userDefaults = UserDefaults.standard
    var audioPlayer:AVAudioPlayer?
    
    var verificationTimer: Timer?
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    
    // Setting display based on settings
    override func viewWillAppear(_ animated: Bool) {
        let displaySetting = userDefaults.integer(forKey: "UTGuesserDarkMode")
        if displaySetting == displayTypeEnum.system.rawValue {
            overrideUserInterfaceStyle = .unspecified
        } else if displaySetting == displayTypeEnum.dark.rawValue {
            overrideUserInterfaceStyle = .dark
        } else if displaySetting == displayTypeEnum.light.rawValue{
            overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !self.verifyEmailCheck() {
            playButton.isEnabled = false
            uploadButton.isEnabled = false
            leaderboardButton.isEnabled = false
            profileButton.isEnabled = false
            startVerificationTimer()
        }
    }
    
    func startVerificationTimer() {
        // Invalidate any existing timer to avoid duplicates
        verificationTimer?.invalidate()
        
        // Create a new timer that fires every 2 seconds
        verificationTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            // Check email verification status
            DispatchQueue.main.async {
                self.verifyEmailCheck()
            }
        }
    }
    func stopVerificationTimer() {
        verificationTimer?.invalidate()
    }
    
    // Get ready for segues (currently just to the main tab controller)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
        
        // Determine if we're segueing to the tab controller & which page to display
        if let tabBarController = segue.destination as? MainTabBarVC {
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
    
    func verifyEmailCheck() -> Bool{
        if let user = Auth.auth().currentUser {
            user.reload()
            if !user.isEmailVerified {
                print("User is not verified")
                let alertController = UIAlertController(title: "Please Verify Your Email", message: "An email verification link has been sent to your inbox please click the verification link to verify your account.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                let resendButton = UIAlertAction(title: "Resend Email", style: .default) {(action) in
                    user.sendEmailVerification { error in
                        if let error = error {
                            print("Error sending verification email: \(error.localizedDescription)")
                        } else {
                            print("Verification email sent successfully.")
                        }
                    }
                }
                alertController.addAction(okAction)
                alertController.addAction(resendButton)
                self.present(alertController, animated: true, completion: nil)
                return false
            } else {
                print("User is Verified")
                DispatchQueue.main.async {
                    self.playButton.isEnabled = true
                    self.uploadButton.isEnabled = true
                    self.leaderboardButton.isEnabled = true
                    self.profileButton.isEnabled = true
                }
            }
        }
        return true
    }
}
