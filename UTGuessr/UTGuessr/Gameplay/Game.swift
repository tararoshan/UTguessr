//
//  Game.swift
//  UTGuessr
//
//  Created by Teresa Luo on 10/11/23.
//

import Foundation
import CoreLocation
import CoreData
import UIKit

class Game {
    let NUM_ROUNDS:Int = 5
    let MAX_ROUND_SCORE:Int = 1000
    
    var roundScores:[Int]
    var roundImagesAndLocations:[ImageAndLocation]
    var currentRound:Int
    
    init() {
        self.roundScores = []
        self.currentRound = 1
        self.roundImagesAndLocations = []
        self.populateRoundImageAndLocation()
//        self.populateRoundImageAndLocation(self.roundImagesAndLocations)
        print("IMAGES AND LOCATION", self.roundImagesAndLocations)
    }
    
//    func fetchRandomImagesAndLocations() -> [ImageAndLocation] {
//
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let context = appDelegate.persistentContainer.viewContext
//        var allImagesAndLocations:[ImageAndLocation] = []
//
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ImageAndLocationEntity")
//        do {
//            let result = try context.fetch(fetchRequest)
//            for imageAndLocationEntity in result as! [NSManagedObject] {
//                var image = imageAndLocationEntity.value(forKey: "image") as! UIImage
//                var latitude = imageAndLocationEntity.value(forKey: "latitude") as! Float
//                var longitude = imageAndLocationEntity.value(forKey: "longitude") as! Float
//                allImagesAndLocations.append(ImageAndLocation(image: image, location: CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))))
//                print(allImagesAndLocations.last)
//            }
//            return allImagesAndLocations
//        } catch let error as NSError {
//            print("Could not fetch images and locations : \(error), \(error.userInfo)")
//        }
//
//        return []
        
        
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageAndLocationEntity")
//        request.predicate = NSPredicate(format: "duedate > %@", due as NSDate)
//
//        // find out how many items are there
//        let totalResults = try! context.count(for: request)
//        if totalResults > 0 {
//            // randomlize offset
//            request.fetchOffset = Int.random(in: 0..<totalResults)
//            request.fetchLimit = 5
//
//            let result = try! context.fetch(request) as! [ImageAndLocationEntity]
//            return result
//        }
//
//        return nil
//    }
    
    func populateRoundImageAndLocation() {
        // Go into Core Data and get 5 random images and location
        // TODO: Core Data
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ImageAndLocationEntity")
        do {
            let result = try context.fetch(fetchRequest)
            print("RESULT", result)
            for imageAndLocationEntity in result {
//                let image = imageAndLocationEntity.value(forKey: "image") as? UIImage
//                let latitude = imageAndLocationEntity.value(forKey: "latitude") as? Float
//                let longitude = imageAndLocationEntity.value(forKey: "longitude") as? Float
                
                guard let image = imageAndLocationEntity.value(forKey: "image") as? UIImage,
                      let latitude = imageAndLocationEntity.value(forKey: "latitude") as? Float,
                      let longitude = imageAndLocationEntity.value(forKey: "longitude") as? Float else {
                    print("Cannot cast data to types")
                    abort()
                }
                
                self.roundImagesAndLocations.append(ImageAndLocation(image: image, location: CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))))
                print(self.roundImagesAndLocations.last!.location.latitude)
            }
        } catch let error as NSError {
            print("Could not fetch images and locations : \(error), \(error.userInfo)")
        }
        
        // For now, populate with dummy values
//        for _ in 1...5 {
//            self.roundImagesAndLocations.append(ImageAndLocation(image: , location: CLLocationCoordinate2DMake(30.2862, -97.7394)))
//        }
    }
    
    func isOver() -> Bool{
        return self.currentRound > self.NUM_ROUNDS
    }
    
    func finishRound(userCoordinate:CLLocationCoordinate2D) {
        self.roundScores.append(calculateRoundScore(
            userCoordinate: userCoordinate,
            actualCoordinate: self.roundImagesAndLocations[currentRound - 1].location))
        self.currentRound += 1
    }
    
    func calculateRoundScore(userCoordinate:CLLocationCoordinate2D, actualCoordinate:CLLocationCoordinate2D) -> Int {
        let from = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let to = CLLocation(latitude: actualCoordinate.latitude, longitude: actualCoordinate.longitude)
        let distance = to.distance(from: from).magnitude
        let score = MAX_ROUND_SCORE - Int(distance) < 0 ? 0 : MAX_ROUND_SCORE - Int(distance)
        print("Calculated distance: \(distance)")
        print("Calculated score: \(score)")
        return score
    }
}
