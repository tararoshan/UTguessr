//
//  LoadScreenViewController.swift
//  UTGuessr
//
//  Created by Alex Lu on 11/3/23.
//

import UIKit
import FirebaseStorage

let leaderboardManager = LeaderboardManager()

class LoadScreenViewController: UIViewController {
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Preload images and locations into the cache
        Task {
            await loadImagesAndLocationsToCache()
        }
        // Prepopulate the leadboard
        leaderboardManager.populateTop25Users()
        self.performSegue(withIdentifier: "LoadingDone", sender: nil)
    }
    
    // Load the images and locations from Firestore into local cache
    func loadImagesAndLocationsToCache() async {
        ImageAndLocationDataManager.shared.preFetchData { result in
            switch result {
            case .success(let items):
                print("Pre-fetched items: \(items)")
            case .failure(let error):
                // Handle the error
                print("Error pre-fetching items: \(error.localizedDescription)")
            }
        }
    }
    
    func appLoad() async{
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images")
        var imageFiles:[StorageReference] = []
        
        let dg = DispatchGroup()
        dg.enter()
        Task {loadCoreLocations()
            dg.leave()}
        dg.enter()
        imageRef.listAll() {(result, error) in
                if let error = error {
                    print(error.localizedDescription.description)
                    return
                }
                if let result = result {
                    imageFiles = result.items
                    if result.items.count != self.checkImageFolder(){
                        self.loadImages()
                    }
                }
                dg.leave()
            }
            
        dg.notify(queue: .main) {
            print(imageFiles)
            dg.enter()
            
            dg.leave()
            self.performSegue(withIdentifier: "LoadingDone", sender: nil)
        }
    }
    
    func checkImageFolder() -> Int {
        do {
            //  get reference to document directory
            let dd = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let imageFolderPath = dd.appendingPathComponent("images")
            if FileManager.default.fileExists(atPath: imageFolderPath.path()){
                print("Image folder already exists")
            } else {
                print("Image folder does not exist")
                try FileManager.default.createDirectory(at: imageFolderPath, withIntermediateDirectories: false, attributes: nil)
                print("Image folder created")
                return 0
            }
            let fileUrls = try FileManager.default.contentsOfDirectory(at: imageFolderPath, includingPropertiesForKeys: nil)
            print("Documents", fileUrls.count)
            return fileUrls.count
        } catch{
            print(error)
        }
        return -1
    }
    
    func loadImages() {
        let storageRef = storage.reference()
        let fimageRef = storageRef.child("images")
        do {
            let dd = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let imageFolderPath = dd.appendingPathComponent("images")
            let imageFiles = try FileManager.default.contentsOfDirectory(at: imageFolderPath, includingPropertiesForKeys: nil)
            
            for imageFile in imageFiles {
                try FileManager.default.removeItem(at: imageFile)
                print("Removed \(imageFile.lastPathComponent)")
            }
            fimageRef.listAll() {(result, error) in
                if let error = error {
                    print(error.localizedDescription.description)
                    return
                }
                for item in result!.items {
                    let localURL = imageFolderPath.appending(path: item.name)
                    let downloadTask = item.write(toFile: localURL) {
                        url, error in
                        if let error = error{
                            print(error)
                        } else {
                            print("Loaded \(item.name) to local storage")
                        }
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Gets the top 25 users by high score from Firebase Firestore
    func loadCoreLocations() {
        let coreLocationsRef = storage.reference(withPath:"CoreLocations.txt")
        do {
            let dd = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let coreLocationsPath = dd.appendingPathComponent("CoreLocations.txt")
            do {
                try FileManager.default.removeItem(at: coreLocationsPath)
            } catch {
                print(error.localizedDescription)
            }
            let downloadTask = coreLocationsRef.write(toFile: coreLocationsPath) {
                url, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Loaded \(coreLocationsRef.name) to local storage")
                }

            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
