//
//  LogInViewController.swift
//  UTGuessr
//
//  Created by Megan Sickler on 10/12/23.
//

import UIKit
import FirebaseAuth
import AVFAudio

// Login screen
class LogInViewController: UIViewController, UITextFieldDelegate {
    
    // Email and password fields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let signUpSegueIdentifier = "signUpSegue"
    
    var audioPlayer: AVAudioPlayer?
    
    let userDefaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        let displaySetting = userDefaults.integer(forKey: "UTGuesserDarkMode")
        if displaySetting == displayTypeEnum.system.rawValue {
            overrideUserInterfaceStyle = .unspecified
        } else if displaySetting == displayTypeEnum.dark.rawValue {
            overrideUserInterfaceStyle = .dark
        } else if displaySetting == displayTypeEnum.light.rawValue{
            overrideUserInterfaceStyle = .light
        }
        emailTextField.overrideUserInterfaceStyle = .light
        passwordTextField.overrideUserInterfaceStyle = .light
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Handles login button click by logging in or alerting user to an error
    @IBAction func logIn(_ sender: Any) {

        Auth.auth().signIn(
            withEmail: emailTextField.text!,
            password: passwordTextField.text!
        ) {
            (authResult,error) in
           if let error = error as NSError? {
               let loginErrorAlert = UIAlertController(
                   title: "Login Error",
                   message: error.localizedDescription,
                   preferredStyle: .alert)
               loginErrorAlert.addAction(UIAlertAction(title: "OK", style: .default))
               self.present(loginErrorAlert, animated: true)
           } else {
                self.performSegue(withIdentifier: "logInSegue", sender: self)
                
                if !self.userDefaults.bool(forKey: "UTGuesserSoundOff") {
                    let path = Bundle.main.path(forResource: "click.mp3", ofType: nil)!
                    let url = URL(fileURLWithPath: path)
                    
                    do {
                        self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                        self.audioPlayer!.play()
                    } catch {
                        print("Couldn't load sound effect.")
                    }
                }
            }
       }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == signUpSegueIdentifier {
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
        }
    }
}
