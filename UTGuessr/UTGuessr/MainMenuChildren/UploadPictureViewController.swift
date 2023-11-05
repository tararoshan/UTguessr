//
//  UploadPictureViewController.swift
//  UTGuessr
//
//  Created by Alex Lu on 11/4/23.
//

import UIKit

class UploadPictureViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var uploadPhotoButton: UIButton!
    var imagePicker = UIImagePickerController()
    
    let userDefaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        if userDefaults.bool(forKey: "UTGuesserDarkMode") {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func takePhotoPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                    print("Button capture")

                    imagePicker.delegate = self
                    imagePicker.sourceType = .savedPhotosAlbum // TOOD: CHANGE TO .camera in final. using album for debug purposes
                    imagePicker.allowsEditing = false

                    present(imagePicker, animated: true, completion: nil)
            }
    }
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
            self.dismiss(animated: true, completion: { () -> Void in

            })

//            imageView.image = image
    }
    @IBAction func uploadPhotoPressed(_ sender: Any) {
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
