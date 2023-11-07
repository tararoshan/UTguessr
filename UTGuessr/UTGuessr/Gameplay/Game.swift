//
//  Game.swift
//  UTGuessr
//
//  Created by Teresa Luo on 10/11/23.
//

import Foundation
import CoreLocation
import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol FetchCountDelegate {
     func didFetchCount(count:Int)
}

protocol FetchImageAndLocationDelegate {
     func didFetch(data:ImageAndLocation)
}

class Game: FetchCountDelegate, FetchImageAndLocationDelegate {
    let NUM_ROUNDS:Int = 5
    let MAX_ROUND_SCORE:Int = 1000
    
    var roundScores:[Int]
    var roundImagesAndLocations:[ImageAndLocation]
    var currentRound:Int
//    var fetchedImagesAndLocations:Bool
    
    var viewController:GameViewController!
    
    let db = Firestore.firestore()
    
    init() {
        self.roundScores = []
        self.currentRound = 1
        self.roundImagesAndLocations = []
//        self.fetchedImagesAndLocations = false
        self.populateRoundImageAndLocation()
        print("IMAGES AND LOCATION: ", self.roundImagesAndLocations)
    }
    
    func populateRoundImageAndLocation() {
        // Go into Firestore and get 5 random images and location
        
        // Get the number of images
        let countDocRef = self.db.collection("count").document("count")
        countDocRef.getDocument {
            (document, error) in
            if let document = document, document.exists {
                let count = document.data()!["image_and_location_count"]! as! Int
                print("COUNT : \(count)")
                self.didFetchCount(count: count)
            } else {
                print("Firebase Firestore: Can't find count")
            }
        }
    }
    
    // We have the count, now get random images
    func didFetchCount(count: Int) {
        // Generate 5 random image IDs between 0 and count
        var imageIDs = Set<Int>()
        while imageIDs.count < NUM_ROUNDS {
            imageIDs.insert(Int.random(in: 0..<count))
        }
        
        print("RANDOM IDS: \(imageIDs)")
        
        // Query for images with our random IDs
        let ref = self.db.collection("images_and_locations")
        for imageID in imageIDs {
            ref.document(String(imageID)).getDocument {
                (document, error) in
                if let document = document, document.exists {
                    let imageData = document.data()!["image"]! as! Data
                    let latitude = document.data()!["latitude"]! as! Double
                    let longitude = document.data()!["longitude"]! as! Double
                    
                    let imageAndLocation = ImageAndLocation(image: UIImage(data: imageData)!, location: CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)))
                    
                    self.didFetch(data: imageAndLocation)
                } else {
                    print("Firebase Firestore: Can't find image \(imageID)")
                }
            }
        }
    }
    
    // We have the ImageAndLocation, now append to roundImagesAndLocations
    func didFetch(data: ImageAndLocation) {
        print("APPENDING \(data)")
        self.roundImagesAndLocations.append(data)
        
        if self.roundImagesAndLocations.count == NUM_ROUNDS {
            print("SETTING FETCHED TO TRUE")
            self.viewController.gameFinishedFetching = true
//            self.fetchedImagesAndLocations = true
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
