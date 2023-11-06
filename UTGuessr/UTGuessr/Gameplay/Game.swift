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
import FirebaseFirestore
import FirebaseAuth

class Game {
    let NUM_ROUNDS:Int = 5
    let MAX_ROUND_SCORE:Int = 1000
    
    var roundScores:[Int]
    var roundImagesAndLocations:[ImageAndLocation]
    var currentRound:Int
    
    let db = Firestore.firestore()
    
    init() {
        self.roundScores = []
        self.currentRound = 1
        self.roundImagesAndLocations = []
        self.populateRoundImageAndLocation()
        print("IMAGES AND LOCATION", self.roundImagesAndLocations)
    }
    
    func populateRoundImageAndLocation() {
        // Go into Core Data and get 5 random images and location
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ImageAndLocationEntity")
        do {
            let result = try context.fetch(fetchRequest)
            print("RESULT", result)
            for imageAndLocationEntity in result {
                
                guard let imageData = imageAndLocationEntity.value(forKey: "image") as? Data,
                      let latitude = imageAndLocationEntity.value(forKey: "latitude") as? Double,
                      let longitude = imageAndLocationEntity.value(forKey: "longitude") as? Double else {
                    print("Cannot cast data to types")
                    abort()
                }
                
                self.roundImagesAndLocations.append(ImageAndLocation(image: UIImage(data: imageData)!, location: CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))))
                // Debugging log
                // print(self.roundImagesAndLocations.last!.location.latitude)
            }
        } catch let error as NSError {
            print("Could not fetch images and locations : \(error), \(error.userInfo)")
        }
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
    
    // Updates user scoring infomation in the database
    func finishGame() {
        let userDocRef = self.db.collection("users").document(Auth.auth().currentUser!.email!)
        userDocRef.getDocument {
            (document, error) in
            if let document = document, document.exists {
                let averageScore = document.data()!["average_score"]! as! Float
                let highScore = document.data()!["high_score"]! as! Int
                let gamesPlayed = document.data()!["games_played"]! as! Int
                
                let currentRoundScore = self.roundScores.reduce(0, +)
                
                // Update the high score
                if highScore < currentRoundScore {
                    userDocRef.setData([ "high_score": currentRoundScore ], merge: true)
                    print("Firebase Firestore: Wrote new high score of \(currentRoundScore) from \(highScore)")
                }
                
                // Update the games played
                userDocRef.setData([ "games_played": gamesPlayed + 1 ], merge: true)
                print("Firebase Firestore: Wrote new games played of \(gamesPlayed + 1) from \(gamesPlayed)")
                
                // Update the average score
                let newAverageScore = self.calculateNewAverageScore(averageScore: averageScore, gamesPlayed: gamesPlayed, currentRoundScore: currentRoundScore)
                userDocRef.setData([ "average_score": newAverageScore], merge: true)
                print("Firebase Firestore: Wrote new average score of \(newAverageScore) from \(averageScore)")
            } else {
                print("Firebase Firestore: Can't find user data")
            }
        }
    }
    
    func calculateNewAverageScore(averageScore:Float, gamesPlayed:Int, currentRoundScore:Int) -> Float {
        return (averageScore * Float(gamesPlayed) + Float(currentRoundScore)) / (Float(gamesPlayed) + 1)
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
