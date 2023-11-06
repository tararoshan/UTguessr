//
//  ProfileVC.swift
//  UTGuessr
//
//  Created by tara on 10/28/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var gamesPlayedLabel: UILabel!
    @IBOutlet weak var averageScoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    @IBOutlet weak var competitiveGamesPlayedLabel: UILabel!
    @IBOutlet weak var gamesWonLabel: UILabel!
    
    let userDefaults = UserDefaults.standard
    let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        if userDefaults.bool(forKey: "UTGuesserDarkMode") {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
        
        // Get user information from database
        let userDocRef = self.db.collection("users").document(Auth.auth().currentUser!.email!)
        userDocRef.getDocument {
            (document, error) in
            if let document = document, document.exists {
                let averageScore = document.data()!["average_score"]! as! Float
                let highScore = document.data()!["high_score"]! as! Int
                let gamesPlayed = document.data()!["games_played"]! as! Int
                
                let username = document.data()!["username"]! as! String
                let profileImage = document.data()!["profile_image"] as? UIImage
                
                if profileImage != nil {
                    // TODO: put profile image
                    print("PROFILE IMAGE NOT NULL")
                    print(profileImage)
                } else {
                    self.profileImage.image = UIImage(named: "defaultProfileImage")
                }
                
                self.usernameLabel.text = username
                self.gamesPlayedLabel.text = "Games Played: \(gamesPlayed)"
                self.averageScoreLabel.text = "Average Score: \(Int(averageScore))"
                self.highScoreLabel.text = "High Score: \(highScore)"
            } else {
                print("Firebase Firestore: Can't find user data")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set rounded borders (make into a circle)
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        // Allow the picture to work like a button as well
        let photoTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImage.addGestureRecognizer(photoTap)
        profileImage.isUserInteractionEnabled = true
        // Allow the username to be changed
        usernameLabel.lineBreakMode = .byCharWrapping
        let usernameTap = UITapGestureRecognizer(target: self, action: #selector(usernameTapped))
        usernameLabel.addGestureRecognizer(usernameTap)
        usernameLabel.isUserInteractionEnabled = true
        
        // TODO: unhide when competitive is implemented
        competitiveGamesPlayedLabel.text = "Unavailable"
        gamesWonLabel.isHidden = true
    }
    
    // Runs when the username is tapped
    @objc func usernameTapped() {
        let controller = UIAlertController(
            title: "Set Username",
            message: nil,
            preferredStyle: .alert)
        
        let usernameTakenController = UIAlertController(
            title: "Username already taken",
            message: "Please enter another username.",
            preferredStyle: .alert)
        
        usernameTakenController.addAction(UIAlertAction(
            title: "OK",
            style: .default))
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        controller.addTextField(configurationHandler: {
            (textField) in
            textField.placeholder = "New Username" } )
        controller.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: {
                (action) in
                let enteredText = controller.textFields![0].text

                // TODO: if username already exists, update text of alert
                self.db.collection("users").whereField("username", isEqualTo: enteredText).getDocuments() {
                    (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        if querySnapshot!.documents.count > 0 {
                            self.present(usernameTakenController, animated:true)
                        } else {
                            self.usernameLabel.text = enteredText!
                            // Update the username in the database
                            self.db.collection("users").document((Auth.auth().currentUser?.email)!).setData([ "username": enteredText ], merge: true)
                        }
                    }
                }
            }
        ))
        present(controller, animated:true)
    }
    
    // Runs when the profile image is tapped
    @objc func profileImageTapped() {
        // Choose between the camera and the photo library
        let controller = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet)
        
        controller.addAction(UIAlertAction(
            title: "Upload from Camera Roll",
            style: .default,
            handler: {
                (action) in
                self.choosePickerType(source: .savedPhotosAlbum)
            } ))
        controller.addAction(UIAlertAction(
            title: "Take Photo",
            style: .default,
            handler: {
                (action) in
                self.choosePickerType(source: .camera)
            } ))
        controller.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel))
        present(controller, animated: true)
    }
    
    func choosePickerType(source: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        // Choose between the camera and the photo library
        imagePickerController.sourceType = source
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let chosenImage = info[.originalImage] as? UIImage {
            profileImage.image = chosenImage
            profileImage.contentMode = .scaleAspectFill
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
