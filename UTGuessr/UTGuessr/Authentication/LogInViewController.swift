//
//  LogInViewController.swift
//  UTGuessr
//
//  Created by Megan Sickler on 10/12/23.
//

import UIKit
import FirebaseAuth

// login screen
class LogInViewController: UIViewController {
    
    // email and password fields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let userDefaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        if userDefaults.bool(forKey: "UTGuesserDarkMode") {
            overrideUserInterfaceStyle = .dark
            emailTextField.overrideUserInterfaceStyle = .light
            passwordTextField.overrideUserInterfaceStyle = .light
        } else {
            overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // handles login button click by logging in or alerting user to an error
    @IBAction func logIn(_ sender: Any) {
        Auth.auth().signIn(
            withEmail: emailTextField.text!,
            password: passwordTextField.text!
        ) {
            (authResult,error) in
                if let error = error as NSError? {
                    let loginErrorAlert = UIAlertController(
                        title: "Login Error",
                        message: error.localizedDescription, // goal for later: make the errors more understandable for a user
                        preferredStyle: .alert)
                    loginErrorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(loginErrorAlert, animated: true)
                } else {
                    self.performSegue(withIdentifier: "logInSegue", sender: self)
                }
        }
    }
}
