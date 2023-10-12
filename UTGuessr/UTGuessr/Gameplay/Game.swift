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
    var scores:[Int] = []
    var currentRound = 1
    
    func calculateRoundScore(userCoordinate:CLLocationCoordinate2D, actualCoordinate:CLLocationCoordinate2D) -> Int {
        return 0
    }
    
    func isLastRound() -> Bool {
        return currentRound == NUM_ROUNDS
    }
}
