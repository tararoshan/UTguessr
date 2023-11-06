//
//  SignUpViewController.swift
//  UTGuessr
//
//  Created by Megan Sickler on 10/12/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// signup screen
class SignUpViewController: UIViewController, UITextFieldDelegate {

    // fields for email, password, and password confirmation
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    
    let userDefaults = UserDefaults.standard
    
    let db = Firestore.firestore()
    
    var username:String!
    
    override func viewWillAppear(_ animated: Bool) {
        if userDefaults.bool(forKey: "UTGuesserDarkMode") {
            overrideUserInterfaceStyle = .dark
            emailTextField.overrideUserInterfaceStyle = .light
            passwordTextField.overrideUserInterfaceStyle = .light
            passwordConfirmationTextField.overrideUserInterfaceStyle = .light
        } else {
            overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.passwordConfirmationTextField.delegate = self
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
            
            // add new user to the database
            print("************** CREATING NEW USER IN FIRESTORE **************")
            self.db.collection("users").document(self.emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)).setData([
                "profile_image": nil,
                "games_played": 0,
                "average_score": 0,
                "high_score": 0
            ]) { err in
                if let err = err {
                    print("Firebase Firestore: Error adding document: \(err)")
                } else {
                    print("Firebase Firestore: Document successfully written!")
                }
            }
            self.incrementUserCountAndSetUsername()
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
    
    func incrementUserCountAndSetUsername() {
        // get the number of users already registered
        let countDocRef = self.db.collection("count").document("count")
        countDocRef.getDocument {
            (document, error) in
            if let document = document, document.exists {
                let count = document.data()!["count"]! as! Int
                print("COUNT : \(count)")
                
                // change the count to count + 1
                self.db.collection("count").document("count").setData([ "count": count + 1 ], merge: true)
                print("Firebase Firestore: Wrote new user count of \(count + 1)")
                
                // set the username of the user
                self.db.collection("users").document(self.emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)).setData([ "username": "user\(count)" ], merge: true)
                
                print("**************WROTE USER TO DB**************")
            } else {
                print("Firebase Firestore: Can't find count")
            }
        }
    }
}
