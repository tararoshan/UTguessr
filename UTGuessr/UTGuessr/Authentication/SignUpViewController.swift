//
//  SignUpViewController.swift
//  UTGuessr
//
//  Created by Megan Sickler on 10/12/23.
//

import AVFAudio
import FirebaseAuth
import FirebaseFirestore
import UIKit

// Signup screen
class SignUpViewController: UIViewController, UITextFieldDelegate {

    // Fields for email, password, and password confirmation
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!

    let logInSegueIdentifier = "logInSegue"

    // Info for display and sound settings
    let userDefaults = UserDefaults.standard
    var audioPlayer: AVAudioPlayer?

    let db = Firestore.firestore()

    var username: String!

    // Setting display based on settings
    override func viewWillAppear(_ animated: Bool) {
        let displaySetting = userDefaults.integer(forKey: "UTGuesserDarkMode")
        if displaySetting == displayTypeEnum.system.rawValue {
            overrideUserInterfaceStyle = .unspecified
        } else if displaySetting == displayTypeEnum.dark.rawValue {
            overrideUserInterfaceStyle = .dark
        } else if displaySetting == displayTypeEnum.light.rawValue {
            overrideUserInterfaceStyle = .light
        }
        emailTextField.overrideUserInterfaceStyle = .light
        passwordTextField.overrideUserInterfaceStyle = .light
        passwordConfirmationTextField.overrideUserInterfaceStyle = .light
    }

    // Setting delegates
    override func viewDidLoad() {
        super.viewDidLoad()

        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.passwordConfirmationTextField.delegate = self
    }

    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // Handles signup button click by signing up or alerting user to an error
    @IBAction func signUp(_ sender: Any) {
        if passwordTextField.text! == passwordConfirmationTextField.text! {
            Auth.auth().createUser(
                withEmail: emailTextField.text!,
                password: passwordTextField.text!
            ) {
                (authResult, error) in
                if let error = error as NSError? {  // Alert user to error
                    let signupErrorAlert = UIAlertController(
                        title: "Signup Error",
                        message: error.localizedDescription,
                        preferredStyle: .alert)
                    signupErrorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(signupErrorAlert, animated: true)
                } else {  // Prompt user to verify email and sign them up
                    // Email verification logic
                    authResult?.user.sendEmailVerification {
                        (error) in
                        if let error = error {
                            print(
                                "Failed sending email verification: \(error.localizedDescription)")
                        } else {
                            print("Email verification sent")
                        }
                    }
                    let alertController = UIAlertController(
                        title: "Verify Email",
                        message:
                            "An email verification link has been sent to your inbox please click the verification link to verify your account.",
                        preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "signUpSegue", sender: self)
                        }
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)

                    // Button click sound effect
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

                    // Adding new user to the database
                    print("************** CREATING NEW USER IN FIRESTORE **************")
                    self.db.collection("users").document(
                        self.emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                    ).setData([
                        "profile_image": nil,
                        "games_played": 0,
                        "average_score": 0,
                        "high_score": 0,
                        "images_uploaded": 0,
                    ]) { err in
                        if let err = err {
                            print("Firebase Firestore: Error adding document: \(err)")
                        } else {
                            print("Firebase Firestore: Document successfully written!")
                        }
                    }
                    self.incrementUserCountAndSetUsername()
                }
            }
        } else {  // Catching password confirmation error
            let badPasswordConfirmationAlert = UIAlertController(
                title: "Signup Error",
                message: "The contents of the two password fields do not match.",
                preferredStyle: .alert)
            badPasswordConfirmationAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(badPasswordConfirmationAlert, animated: true)
        }
    }

    // Incrementing user count and setting new username
    func incrementUserCountAndSetUsername() {

        // Get the number of users already registered
        let countDocRef = self.db.collection("count").document("count")
        countDocRef.getDocument {
            (document, error) in
            if let document = document, document.exists {
                let count = document.data()!["user_count"]! as! Int
                print("COUNT : \(count)")

                // Change the count to count + 1
                self.db.collection("count").document("count").setData(
                    ["user_count": count + 1], merge: true)
                print("Firebase Firestore: Wrote new user count of \(count + 1)")

                // Set the username of the user
                self.db.collection("users").document(
                    self.emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                ).setData(["username": "user\(count)"], merge: true)

                print("**************WROTE USER TO DB**************")
            } else {
                print("Firebase Firestore: Can't find count")
            }
        }
    }

    // Called before segue to 'log in' page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == logInSegueIdentifier {

            // Button click sound effect
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
