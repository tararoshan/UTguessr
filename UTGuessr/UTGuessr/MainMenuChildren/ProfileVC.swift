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

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var gamesPlayedLabel: UILabel!
    @IBOutlet weak var averageScoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    let userDefaults = UserDefaults.standard
    let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        if userDefaults.bool(forKey: "UTGuesserDarkMode") {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get user information from database
        
        let userDocRef = self.db.collection("users").document(Auth.auth().currentUser!.email!)
        userDocRef.getDocument {
            (document, error) in
            if let document = document, document.exists {
                let averageScore = document.data()!["average_score"]! as! Float
                let highScore = document.data()!["high_score"]! as! Int
                let gamesPlayed = document.data()!["games_played"]! as! Int
                
                let username = document.data()!["username"]! as! String
                let profileImage = document.data()!["profile_image"]
                
                self.usernameLabel.text = username
                self.gamesPlayedLabel.text = "Games Played: \(gamesPlayed)"
                self.averageScoreLabel.text = "Average Score: \(Int(averageScore))"
                self.highScoreLabel.text = "High Score: \(highScore)"
            } else {
                print("Firebase Firestore: Can't find user data")
            }
        }
        
        // Set rounded borders (make into a circle)
        profilePic.layer.cornerRadius = profilePic.bounds.width / 2
        // Allow the picture to work like a button as well
        let photoTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profilePic.addGestureRecognizer(photoTap)
        profilePic.isUserInteractionEnabled = true
        // Allow the username to be changed
        usernameLabel.lineBreakMode = .byCharWrapping
        let usernameTap = UITapGestureRecognizer(target: self, action: #selector(usernameTapped))
        usernameLabel.addGestureRecognizer(usernameTap)
        usernameLabel.isUserInteractionEnabled = true
    }
    
    // Runs when the username is tapped
    @objc func usernameTapped() {
        let controller = UIAlertController(
            title: "Set Username",
            message: nil,
            preferredStyle: .alert)
        
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
                self.usernameLabel.text = enteredText!
                
                // TODO: if username already exists, update text of alert
                
                // TODO: Update the username in the database
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
            profilePic.image = chosenImage
            profilePic.contentMode = .scaleAspectFill
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
