//
//  Game.swift
//  UTGuessr
//
//  Created by Teresa Luo on 10/11/23.
//

import Foundation
import CoreLocation

class Game {
    let NUM_ROUNDS:Int = 5
    let MAX_ROUND_SCORE:Int = 3000
    
    var roundScores:[Int]
    var roundImagesAndLocations:[ImageAndLocation]
    var currentRound:Int
    
    init() {
        self.roundScores = []
        self.currentRound = 1
        self.roundImagesAndLocations = []
        self.populateRoundImageAndLocation(self.roundImagesAndLocations)
    }
    
    func populateRoundImageAndLocation(_ roundImagesAndLocations:[ImageAndLocation]) {
        // Go into Core Data and get 5 random images and location
        // TODO: Core Data
        
        
        // For now, populate with dummy values
        for _ in 1...5 {
            self.roundImagesAndLocations.append(ImageAndLocation(image: "", location: CLLocationCoordinate2DMake(30.293307, -97.741870)))
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
