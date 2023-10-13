//
//  SignUpViewController.swift
//  UTGuessr
//
//  Created by Megan Sickler on 10/12/23.
//

import UIKit
import FirebaseAuth

// signup screen
class SignUpViewController: UIViewController {

    // fields for email, password, and password confirmation
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // handles signup button click by signing up or alerting user to an error
    @IBAction func signUp(_ sender: Any) {
        if passwordTextField.text! == passwordConfirmationTextField.text! {
            Auth.auth().createUser(
                withEmail: emailTextField.text!,
                password: passwordTextField.text!
            ) {
                // catching firebase error
                (authResult,error) in
                    if let error = error as NSError? {
                        let signupErrorAlert = UIAlertController(
                            title: "Signup Error",
                            message: error.localizedDescription, // goal for later: make the errors more understandable for a user
                            preferredStyle: .alert)
                        signupErrorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(signupErrorAlert, animated: true)
                    } else {
                        self.performSegue(withIdentifier: "signUpSegue", sender: self)
                    }
            }
        } else {
            // catching password confirmation error
            let badPasswordConfirmationAlert = UIAlertController(
                title: "Signup Error",
                message: "The contents of the two password fields do not match.",
                preferredStyle: .alert)
            badPasswordConfirmationAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(badPasswordConfirmationAlert, animated: true)
        }
    }
}
