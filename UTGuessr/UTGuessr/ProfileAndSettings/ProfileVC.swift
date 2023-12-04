//
//  ProfileVC.swift
//  UTGuessr
//
//  Created by tara on 10/28/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import AVFAudio

extension String {
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var gamesPlayedLabel: UILabel!
    @IBOutlet weak var averageScoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    @IBOutlet weak var contributorLabel: UILabel!
    
    let userDefaults = UserDefaults.standard
    var audioPlayer:AVAudioPlayer?
    let db = Firestore.firestore()
    
    let settingsSegueIdentifier = "settingsSegue"
    let logOutSegueIdentifier = "logOutSegue"
    
    override func viewWillAppear(_ animated: Bool) {
        let displaySetting = userDefaults.integer(forKey: "UTGuesserDarkMode")
        if displaySetting == displayTypeEnum.system.rawValue {
            overrideUserInterfaceStyle = .unspecified
        } else if displaySetting == displayTypeEnum.dark.rawValue {
            overrideUserInterfaceStyle = .dark
        } else if displaySetting == displayTypeEnum.light.rawValue{
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
                let profileImageData = document.data()!["profile_image"] as? Data
                
                let numImagesUploaded = document.data()!["images_uploaded"] as! Int
                
                if profileImageData != nil {
                    self.profileImage.image = UIImage(data: profileImageData!)
                } else {
                    self.profileImage.image = UIImage(named: "defaultProfileImage")
                }
                
                if numImagesUploaded >= 25 {
                    // Gold Contributor
                    self.contributorLabel.text = "Gold Contributor"
                    self.contributorLabel.textColor = UIColor(red: 228/255.0, green: 202/255.0, blue: 106/255.0, alpha: 1)
                    self.contributorLabel.isHidden = false
                } else if numImagesUploaded >= 10 {
                    // Silver Contributor
                    self.contributorLabel.text = "Silver Contributor"
                    self.contributorLabel.textColor = .lightGray
                    self.contributorLabel.isHidden = false
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
        
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        contributorLabel.layer.cornerRadius = 30.0
        self.view.bringSubviewToFront(profileImage)
        self.view.bringSubviewToFront(usernameLabel)
        self.view.bringSubviewToFront(contributorLabel)
        profileImage.contentMode = .scaleAspectFill
        // Allow the picture to work like a button as well
        let photoTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImage.addGestureRecognizer(photoTap)
        profileImage.isUserInteractionEnabled = true
        // Allow the username to be changed
        usernameLabel.lineBreakMode = .byCharWrapping
        let usernameTap = UITapGestureRecognizer(target: self, action: #selector(usernameTapped))
        usernameLabel.addGestureRecognizer(usernameTap)
        usernameLabel.isUserInteractionEnabled = true
        
        // Hide the contributor label until we load data
        contributorLabel.isHidden = true
    }
    
    // Runs when the username is tapped
    @objc func usernameTapped() {
        let usernameTakenController = UIAlertController(
            title: "Username already taken",
            message: "Please enter another username.",
            preferredStyle: .alert)
        
        usernameTakenController.addAction(UIAlertAction(
            title: "OK",
            style: .default))
        
        let usernameInvalidController = UIAlertController(
            title: "Invalid username",
            message: "Usernames must be less than 20 characters and only contain alpha numeric characters.",
            preferredStyle: .alert)
        
        usernameInvalidController.addAction(UIAlertAction(
            title: "OK",
            style: .default))
        
        let usernameReservedController = UIAlertController(
            title: "Username reserved",
            message: "Please enter another username that is not in the format user#.",
            preferredStyle: .alert)
        
        usernameReservedController.addAction(UIAlertAction(
            title: "OK",
            style: .default))
        
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
                
                if enteredText!.count > 20 || !enteredText!.isAlphanumeric {
                    // The user has entered an invalid username
                    self.present(usernameInvalidController, animated:true)
                } else if enteredText?.prefix(4) == "user" && Int(enteredText!.dropFirst(4)) != nil {
                    // The user has entered a reserved username (user[int])
                    self.present(usernameReservedController, animated:true)
                } else {
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
            
            // Update the database with the new profile picture
            self.db.collection("users").document((Auth.auth().currentUser?.email)!).setData([ "profile_image": chosenImage.jpegData(compressionQuality: 0.25)!], merge: true)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == settingsSegueIdentifier {
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

