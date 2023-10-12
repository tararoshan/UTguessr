//
//  Game.swift
//  UTGuessr
//
//  Created by Teresa Luo on 10/11/23.
//

import Foundation
import CoreLocation

class Game {
    let NUM_ROUNDS = 5
    
    var roundScores:[Int]
    var roundImagesAndLocations:[ImageAndLocation]
    var currentRound:Int
    
    init() {
        self.roundScores = []
        self.currentRound = 1
        self.roundImagesAndLocations = []
        self.populateRoundImageAndLocation()
    }
    
    func goToNextRound() {
        self.currentRound += 1
    }
    
    func populateRoundImageAndLocation(roundImagesAndLocations:[ImageAndLocation]) -> {
        // Go into Core Data and get 5 random images and location
    }
    
    func calculateRoundScore(userCoordinate:CLLocationCoordinate2D, actualCoordinate:CLLocationCoordinate2D) -> Int {
        
        return 0
    }
    
    func isLastRound() -> Bool {
        return currentRound == NUM_ROUNDS
    }
}
