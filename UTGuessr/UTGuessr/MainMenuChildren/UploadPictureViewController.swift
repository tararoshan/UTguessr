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
        DispatchQueue.global().async {
              if CLLocationManager.locationServicesEnabled() {
                  print("LOCATION SERVICES ENABLED")
                  self.locationManager.delegate = self
                  self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
              }
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageView.image = nil
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        curLat = locValue.latitude
        curLong = locValue.longitude
        print("CURRENTLY AT \(locValue.latitude) \(locValue.longitude)")
        addCoordinateToCoreLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    @IBAction func takePhotoPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                    print("Button capture")

                    imagePicker.delegate = self
            imagePicker.sourceType = .camera // TOOD: CHANGE TO .camera in final. using album for debug purposes
                    imagePicker.allowsEditing = true
                    present(imagePicker, animated: true, completion: nil)
            }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            imageView.image = image
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
            print("No image selected")
            return
        }
        uploadPhotoButton.isEnabled = false
        locationManager.requestLocation()
        do {
            let dd = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let imageFolderPath = dd.appendingPathComponent("images")
            let imageFiles = try FileManager.default.contentsOfDirectory(at: imageFolderPath, includingPropertiesForKeys: nil)
            let fileName = imageNameFromImageNumber(imageFiles.count)
            let filePath = imageFolderPath.appendingPathComponent("\(fileName)")
            try imageView.image!.jpegData(compressionQuality: 1.0)?.write(to: filePath)
            let storageRef = storage.reference()
            let fimageRef = storageRef.child("images/\(fileName)")
            
            let uploadTask = fimageRef.putFile(from: filePath, metadata: nil) {metadata, error in
                guard let metadata = metadata else {
                    return
                }
                fimageRef.downloadURL(){
                    (url, error) in
                    guard let downloadURL = url else {
                        return
                    }
                }
                let uploadDone = UIAlertController(title: "Upload Complete", message: "Your picture and location have been successfully uploaded to the server", preferredStyle: .alert)
                uploadDone.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(uploadDone, animated: true, completion: nil)
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
        do {
            let dd = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let coreLocationsFile = dd.appendingPathComponent("CoreLocations.txt")
            let newCord = "\(curLat) \(curLong)\n"
            if let fileHandle = FileHandle(forWritingAtPath: coreLocationsFile.path(percentEncoded: false)) {
                fileHandle.seekToEndOfFile()
                if let data = newCord.data(using: .utf8) {
                    fileHandle.write(data)
                    fileHandle.closeFile()
                    print("Wrote to CoreLocations")
                } else {
                    print("Error in writing file")
                }
            }
            let storageRef = storage.reference()
            let flocRef = storageRef.child("CoreLocations.txt")
            let uploadTask = flocRef.putFile(from: coreLocationsFile, metadata: nil) {metadata, error in
                guard let metadata = metadata else {
                    return
                }
                flocRef.downloadURL(){
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
}
