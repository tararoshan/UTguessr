//
//  UploadPictureViewController.swift
//  UTGuessr
//
//  Created by Alex Lu on 11/4/23.
//

import UIKit
import FirebaseStorage
import CoreLocation
import FirebaseAuth
import FirebaseFirestore

class UploadPictureViewController: UIViewController, UIImagePickerControllerDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, FetchCountDelegate {
    
    
    @IBOutlet weak var uploadPhotoButton: UIButton!
    @IBOutlet weak var savePhotoButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    var imagePicker = UIImagePickerController()
    let userDefaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    var currentLatitude:CLLocationDegrees = 0.0
    var currentLongitude:CLLocationDegrees = 0.0
    
    let db = Firestore.firestore()
    
    var queue: DispatchQueue!
    
    override func viewWillAppear(_ animated: Bool) {
        if userDefaults.bool(forKey: "UTGuesserDarkMode") {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
        
        // Reset image
        imageView.image = UIImage(named: "logo")
        
        // Disable Save Button
        savePhotoButton.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable location services
        locationManager.requestWhenInUseAuthorization()
        DispatchQueue.global().async {
              if CLLocationManager.locationServicesEnabled() {
                  print("LOCATION SERVICES ENABLED")
                  self.locationManager.delegate = self
                  self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
              }
        }
        
        imagePicker.delegate = self
    }
    
    @IBAction func uploadPhotoPressed(_ sender: Any) {
        // Clear the status label
        statusLabel.text = ""
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")

            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum // TODO: CHANGE TO .camera in final. Using album for debug purposes
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
            
            // Image successfully uploaded, enable Save Button
            savePhotoButton.isEnabled = true
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true)
    }
    
    @IBAction func savePhotoPressed(_ sender: Any) {
        // Add photo to firebase
        let countDocRef = self.db.collection("count").document("count")
        countDocRef.getDocument {
            (document, error) in
            if let document = document, document.exists {
                let imageCount = document.data()!["image_and_location_count"]! as! Int
                print("COUNT : \(imageCount)")
                self.db.collection("count").document("count").setData([ "image_and_location_count": imageCount + 1 ], merge: true)
                print("Firebase Firestore: Wrote new image count of \(imageCount + 1)")
                self.didFetchCount(count: imageCount)
            } else {
                print("Firebase Firestore: Can't find count")
            }
        }
    }
    
    // We have the count, now upload the image and the location to Firestore
    func didFetchCount(count:Int) {
        guard let imageData = imageView.image!.jpegData(compressionQuality: 0.25) else {
            print("Error converting image to data")
            return
        }
        
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            print("Error loading image data")
            return
        }
        
        guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            print("Error extracting properties")
            return
        }
        
        var imageLatitute:Double?
        var imageLongitude:Double?
        
        if let gpsData = imageProperties[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
            if let latitude = gpsData[kCGImagePropertyGPSLatitude as String] as? Double,
               let longitude = gpsData[kCGImagePropertyGPSLongitude as String] as? Double {
                print("Image Latitude: \(latitude), Longitude: \(longitude)")
                imageLatitute = latitude
                imageLongitude = longitude
            }
        }
        
        if imageLatitute == nil || imageLongitude == nil {
            print("Coordinates not found in image metadata. Using current location.")
            let locValue:CLLocationCoordinate2D = locationManager.location!.coordinate
            imageLatitute = locValue.latitude
            imageLongitude = locValue.longitude
            print("CURRENTLY AT \(locValue.latitude) \(locValue.longitude)")
        }
        
        if imageLatitute != nil && imageLongitude != nil && imageLatitute != 0.0 && imageLongitude != 0.0 {
            db.collection("images_and_locations").document(String(count)).setData([
                "image": imageData,
                "latitude": imageLatitute!,
                "longitude": imageLongitude!,
            ]) { err in
                if let err = err {
                    print("IMAGES AND LOCATIONS Firebase Firestore: Error adding document: \(err)")
                } else {
                    print("IMAGES AND LOCATIONS Firebase Firestore: Document successfully written!")
                }
            }
            
            // Update the number of photos the user has contributed
            self.db.collection("users").document((Auth.auth().currentUser?.email)!).updateData(["images_uploaded": FieldValue.increment(Int64(1))])
            
            // Set the image to nil again -- do not want to upload the same photo
            imageView.image = UIImage(named: "logo")
            // Disable the Upload Button
            savePhotoButton.isEnabled = false
            statusLabel.text = "Successfully uploaded your image to the database."
        } else {
            print("Latitude and latitude nil. Unable to upload.")
            // Set status label
            statusLabel.text = "Could not locate your position. Unable to save photo to database."
        }
    }
}
