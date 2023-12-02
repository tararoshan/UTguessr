//
//  File.swift
//  UTGuessr
//
//  Created by Teresa Luo on 12/2/23.
//

import Foundation
import Firebase
import FirebaseFirestore

struct LeaderboardEntry {
    let userEmail: String
    let username: String
    var highScore: Int
}

class LeaderboardManager {
    let db = Firestore.firestore()
    var leaderboardEntries: [LeaderboardEntry] = []
    var listeners: [ListenerRegistration] = []

    func listenToHighScores() {
        // Replace "users" with the actual collection name in your Firestore database
        let usersRef = db.collection("users")

        let listener = usersRef.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self,
                  let snapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }

            snapshot.documentChanges.forEach { diff in
                let userData = diff.document.data()
                let userEmail = diff.document.documentID
                guard let username = userData["username"] as? String,
                      let highScore = userData["high_score"] as? Int else {
                    return
                }

                if diff.type == .modified {
                    print("User \(userEmail) updated high score: \(highScore)")
                    // Update the local leaderboard data
                    self.updateLeaderboard(userEmail: userEmail, username: username, highScore: highScore)
                    // Sort and trim the leaderboard to keep only the top 25 entries
                    self.sortAndTrimLeaderboard()
                    // Update your UI or perform any other necessary actions
                }
            }
        }

        listeners.append(listener)
    }

    func updateLeaderboard(userEmail: String, username: String, highScore: Int) {
        // Check if the user is already in the leaderboard
        if let index = leaderboardEntries.firstIndex(where: { $0.userEmail == userEmail }) {
            // Update the existing entry
            leaderboardEntries[index].highScore = highScore
        } else {
            // Add a new entry
            leaderboardEntries.append(LeaderboardEntry(userEmail: userEmail, username: username, highScore: highScore))
        }
    }

    func sortAndTrimLeaderboard() {
        // Sort the leaderboard in descending order based on high scores
        leaderboardEntries.sort { $0.highScore > $1.highScore }
        // Keep only the top 25 entries
        leaderboardEntries = Array(leaderboardEntries.prefix(25))
    }

    // Call this method when you no longer need to listen to high scores
    func stopListening() {
        for listener in listeners {
            listener.remove()
        }
        listeners.removeAll()
    }
}
