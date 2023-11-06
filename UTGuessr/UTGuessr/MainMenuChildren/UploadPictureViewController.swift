//
//  UploadPictureViewController.swift
//  UTGuessr
//
//  Created by Alex Lu on 11/4/23.
//

import UIKit
import FirebaseStorage
import CoreLocation

class UploadPictureViewController: UIViewController, UIImagePickerControllerDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var uploadPhotoButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    let storage = Storage.storage()
    let userDefaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    var curLat:CLLocationDegrees = 0.0
    var curLong:CLLocationDegrees = 0.0
    
    override func viewWillAppear(_ animated: Bool) {
        if userDefaults.bool(forKey: "UTGuesserDarkMode") {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            print("LOCATION SERVICES ENABLED")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }

        // Do any additional setup after loading the view.
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        curLat = locValue.latitude
        curLong = locValue.longitude
        print("CURRENTLY AT \(locValue.latitude) \(locValue.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    @IBAction func takePhotoPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                    print("Button capture")

                    imagePicker.delegate = self
                    imagePicker.sourceType = .savedPhotosAlbum // TOOD: CHANGE TO .camera in final. using album for debug purposes
                    imagePicker.allowsEditing = true

                    present(imagePicker, animated: true, completion: nil)
            }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imageView.image = image
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    @IBAction func uploadPhotoPressed(_ sender: Any) {
        locationManager.requestLocation()
        if imageView.image == nil {
            print("No image selected")
            return
        }
        do {
            let dd = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let imageFolderPath = dd.appendingPathComponent("images")
            let imageFiles = try FileManager.default.contentsOfDirectory(at: imageFolderPath, includingPropertiesForKeys: nil)
            let fileName = imageNameFromImageNumber(imageFiles.count-1)
            let filePath = imageFolderPath.appendingPathComponent("\(fileName)")
            try imageView.image!.jpegData(compressionQuality: 1.0)?.write(to: filePath)
            let storageRef = storage.reference()
            let fimageRef = storageRef.child("images/\(fileName)")
            
            let uploadTask = fimageRef.putFile(from: filePath, metadata: nil) {metadata, error in
                guard let metadata = metadata else {
                    return
                }
                let size = metadata.size
                fimageRef.downloadURL(){
                    (url, error) in
                    guard let downloadURL = url else {
                        return
                    }
                }
            }
            
            
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func imageNameFromImageNumber(_ imageNumber: Int) -> String {
        return "\(String(format: "%04d", imageNumber)).jpeg"
    }
    
    func addCoordinateToCoreLocation() {
        
    }
}
