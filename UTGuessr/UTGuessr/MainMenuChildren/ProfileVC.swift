//
//  ProfileVC.swift
//  UTGuessr
//
//  Created by tara on 10/28/23.
//

import UIKit

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            title: "Set username",
            message: nil,
            preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        controller.addTextField(configurationHandler: {
            (textField) in
            textField.placeholder = "New username" } )
        controller.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: {
                (action) in
                let enteredText = controller.textFields![0].text
                self.usernameLabel.text = enteredText!
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
            title: "Take photo",
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
