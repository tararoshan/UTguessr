//
//  LogInViewController.swift
//  UTGuessr
//
//  Created by Megan Sickler on 10/12/23.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController {
    
    // TODO: make the modal view how you want it
    // TODO: make the login button conditional
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField! // TODO: change to dots
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logIn(_ sender: Any) {
        Auth.auth().signIn(
            withEmail: emailTextField.text!,
            password: passwordTextField.text!
        )
        // TODO: add error message here!
    }
}
