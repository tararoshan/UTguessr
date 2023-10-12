//
//  SignUpViewController.swift
//  UTGuessr
//
//  Created by Megan Sickler on 10/12/23.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    // TODO: make the signup button conditional

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField! // TODO: change to dots
    @IBOutlet weak var passwordConfirmationTextField: UITextField! // TODO: change to dots
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signUp(_ sender: Any) {
        if passwordTextField.text! == passwordConfirmationTextField.text! {
            Auth.auth().createUser(
                withEmail: emailTextField.text!,
                password: passwordTextField.text!
            )
            // TODO: add closure to handle errors
        } else {
            // TODO: add error handling here
        }
    }
}
