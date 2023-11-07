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

class UploadPictureViewController: UIViewController, UIImagePickerControllerDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var uploadPhotoButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    let userDefaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    var curLat:CLLocationDegrees = 0.0
    var curLong:CLLocationDegrees = 0.0
    
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
        
        // Enable location services
        locationManager.requestWhenInUseAuthorization()
        DispatchQueue.global().async {
              if CLLocationManager.locationServicesEnabled() {
                  print("LOCATION SERVICES ENABLED")
                  self.locationManager.delegate = self
                  self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
              }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        curLat = locValue.latitude
        curLong = locValue.longitude
        print("CURRENTLY AT \(locValue.latitude) \(locValue.longitude)")
        addCoordinateToCoreLocation()
    }
    
    func addCoordinateToCoreLocation() {
        // TODO add functionality
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
        if let image = info[.editedImage] as? UIImage {
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
        }
        picker.dismiss(animated: true)
        print("DONE PICKING IMAGE")
        uploadPhotoButton.isEnabled = true
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    @IBAction func uploadPhotoPressed(_ sender: Any) {
        if imageView.image == nil {
            // TODO: make label say no image selected
            print("No image selected")
            return
        }
        // Add photo to firebase. First get the number of images.
        var imageCount = -1
        let countDocRef = self.db.collection("count").document("count")
        countDocRef.getDocument {
            (document, error) in
            if let document = document, document.exists {
                imageCount = document.data()!["image_and_location_count"]! as! Int
                print("COUNT : \(imageCount)")
                // Increment by one (we're about to add an image)
                self.db.collection("count").document("count").setData([ "image_and_location_count": imageCount + 1 ], merge: true)
                print("Firebase Firestore: Wrote new user count of \(imageCount + 1)")
            } else {
                print("Firebase Firestore: Can't find count")
                // TODO end execution here? since we can't access the DB. We could show an alert.
            }
        }
        
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
        
        if let gpsData = imageProperties[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
            if let latitude = gpsData[kCGImagePropertyGPSLatitude as String] as? Double,
               let longitude = gpsData[kCGImagePropertyGPSLongitude as String] as? Double {
                print("Image Latitude: \(latitude), Longitude: \(longitude)")
                
                // TODO change the string of the image URL? idk if String(imageCount) works
                db.collection("images_and_locations").document(String(imageCount)).setData([
                    "image": imageData,
                    "latitude": latitude,
                    "longitude": longitude,
                ]) { err in
                    if let err = err {
                        print("IMAGES AND LOCATIONS Firebase Firestore: Error adding document: \(err)")
                    } else {
                        print("IMAGES AND LOCATIONS Firebase Firestore: Document successfully written!")
                    }
                }
            }
        }
        
        print("Coordinates not found in image metadata. Using current location.")
        // TODO check user's current location & upload the latitude & longitude
        
        // Update the number of photos the user has contributed
        self.db.collection("users").document((Auth.auth().currentUser?.email)!).updateData(["images_added": FieldValue.increment(Int64(1))])
    }
}
