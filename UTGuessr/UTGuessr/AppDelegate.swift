//
//  AppDelegate.swift
//  UTGuessr
//
//  Created by Alex Lu on 10/5/23.
//

import UIKit
import FirebaseCore
import CoreData
import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private func imageNameFromImageNumber(_ imageNumber: Int) -> String {
        return "\(String(format: "%04d", imageNumber)).jpeg"
    }
    
    private func load(imageFileURL:URL) -> UIImage? {
        do {
            let imageData = try Data(contentsOf: imageFileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    func populateFirestoreWithDefaultImages() {
        let imagesAndLocationsDirectory = "CoreImagesAndLocations"
        let locationsFile = "CoreLocations.txt"
        
        let db = Firestore.firestore()
        
        if let imagesAndLocationsDirectoryURL = Bundle.main.url(forResource: imagesAndLocationsDirectory, withExtension: nil) {
            let locationsFileURL = imagesAndLocationsDirectoryURL.appendingPathComponent(locationsFile)
            do {
                let locationsData = try Data(contentsOf: locationsFileURL)
                if let locationsString = String(data: locationsData, encoding: .utf8) {
                    let locationsStringArray = locationsString.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
                    print("NUM IMAGES: \(locationsStringArray.count)")
                    for i in 0...locationsStringArray.count-1 {
                        // Get the image
                        let imageFileURL = imagesAndLocationsDirectoryURL.appendingPathComponent(imageNameFromImageNumber(i))
                        
                        guard let image = load(imageFileURL: imageFileURL) else {
                            print("Error reading image")
                            return
                        }
                        
                        // Get the longitude and latitude
                        let latitudeAndLongitude = locationsStringArray[i].components(separatedBy: " ")
                        guard let latitude = Double(latitudeAndLongitude[0]) else {
                            print("Error reading latitude for image \(imageNameFromImageNumber(i))")
                            return
                        }
                        guard let longitude = Double(latitudeAndLongitude[1]) else {
                            print("Error reading longitude for image \(imageNameFromImageNumber(i))")
                            return
                        }
                        
                        // Add the image and its coordinates to Core Data
                        let imageData = image.jpegData(compressionQuality: 0.25)
                        
                        print("adding image and location \(i)")
                        db.collection("images_and_locations").document(String(i)).setData([
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
                } else {
                    // Handle the case where the file's content can't be converted to a string
                }
            } catch {
                // Handle any errors that might occur during file reading
                print("Error reading from CoreLocations : \(error)")
            }
        } else {
            // Handle the case where the file doesn't exist
            print("Failed to find directory : \(imagesAndLocationsDirectory)")
        }
        
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        // Add core images and core locations to Core Data if needed
        self.populateFirestoreWithDefaultImages()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
            /*
             The persistent container for the application. This implementation
             creates and returns a container, having loaded the store for the
             application to it. This property is optional since there are legitimate
             error conditions that could cause the creation of the store to fail.
             */
            let container = NSPersistentContainer(name: "DataModel")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
        
        // MARK: - Core Data Saving support
        
        func saveContext() {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }


}

