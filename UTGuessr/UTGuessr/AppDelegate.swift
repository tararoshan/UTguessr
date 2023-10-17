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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private func clearCoreData() {
        let context = persistentContainer.viewContext
        // Delete everything from Core Data
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageAndLocationEntity")
        var fetchedResults:[NSManagedObject]
        
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                for result in fetchedResults {
                    context.delete(result)
                }
            }
            saveContext()
        } catch {
            print("Error occurred while clearing data")
            abort()
        }
    }
    
    private func emptyCoreData() -> Bool? {
        let context = persistentContainer.viewContext
        // Checks if Core Data is empty
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageAndLocationEntity")
        
        do {
            let count = try context.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
    
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

    private func readImagesAndLocationsAndAddToCoreData(imagesAndLocationsDirectory:String, locationsFile:String) -> Bool {
        
        let context = persistentContainer.viewContext
        
        if let imagesAndLocationsDirectoryURL = Bundle.main.url(forResource: imagesAndLocationsDirectory, withExtension: nil) {
            let locationsFileURL = imagesAndLocationsDirectoryURL.appendingPathComponent(locationsFile)
            do {
                let locationsData = try Data(contentsOf: locationsFileURL)
                if let locationsString = String(data: locationsData, encoding: .utf8) {
                    let locationsStringArray = locationsString.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
                    for i in 0...locationsStringArray.count-1 {
                        // Get the image
                        let imageFileURL = imagesAndLocationsDirectoryURL.appendingPathComponent(imageNameFromImageNumber(i))
                        
                        guard let image = load(imageFileURL: imageFileURL) else {
                            print("Error reading image")
                            return false
                        }
                        
                        // Get the longitude and latitude
                        let latitudeAndLongitude = locationsStringArray[i].components(separatedBy: " ")
                        guard let latitude = Double(latitudeAndLongitude[0]) else {
                            print("Error reading latitude for image \(imageNameFromImageNumber(i))")
                            return false
                        }
                        guard let longitude = Double(latitudeAndLongitude[1]) else {
                            print("Error reading longitude for image \(imageNameFromImageNumber(i))")
                            return false
                        }
                        
                        // Add the image and its coordinates to Core Data
                        let imageData = image.jpegData(compressionQuality: 1.0)
                        
                        let entityName =  NSEntityDescription.entity(forEntityName: "ImageAndLocationEntity", in: context)!
                        let imageAndLocationEntity = NSManagedObject(entity: entityName, insertInto: context)
                        imageAndLocationEntity.setValue(imageData, forKeyPath: "image")
                        imageAndLocationEntity.setValue(latitude, forKeyPath: "latitude")
                        imageAndLocationEntity.setValue(longitude, forKeyPath: "longitude")
                        
                        print("Adding \(imageNameFromImageNumber(i))")
                        saveContext()
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
        
        return false
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        // Add core images and core locations to Core Data
        let CORE_IMAGES_AND_LOCATIONS = "CoreImagesAndLocations"
        let LOCATIONS_FILE = "CoreLocations.txt"
        
        if let empty = emptyCoreData(), empty == true {
            if !readImagesAndLocationsAndAddToCoreData(imagesAndLocationsDirectory: CORE_IMAGES_AND_LOCATIONS, locationsFile: LOCATIONS_FILE) {
                print("UNABLE TO UPLOAD IMAGES")
            }
        } else {
            print("UNABLE TO DETERMINE IF CORE DATA IS EMPTY")
        }
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

