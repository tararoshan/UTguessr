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
    var username: String
    var highScore: Int
}

class LeaderboardManager {
    let db = Firestore.firestore()
    var leaderboardEntries: [LeaderboardEntry] = []
    var listeners: [ListenerRegistration] = []

    // Start listening to changes in the high score field
    func listenToHighScores() {
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
                }
            }
        }
        listeners.append(listener)
    }
    
    // Start listening to changes in the username field
    func listenToUsernames() {
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
                guard let username = userData["username"] as? String else {
                    return
                }

                if diff.type == .modified {
                    print("User \(userEmail) updated username: \(username)")
                    // Update the local leaderboard data
                    self.updateUsername(userEmail: userEmail, newUsername: username)
                }
            }
        }
        listeners.append(listener)
    }
    
    func updateUsername(userEmail: String, newUsername: String) {
        // Check if the user is on the leaderboard
        if let index = leaderboardEntries.firstIndex(where: { $0.userEmail == userEmail }) {
            // Update the existing entry
            leaderboardEntries[index].username = newUsername
        }
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
    
    func populateTop25Users() {
        let usersRef = self.db.collection("users")
        leaderboardEntries = []
        // Query to get top 25 users by high score
        usersRef.order(by: "high_score", descending: true).limit(to: 25).getDocuments() {
            (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let username = document.data()["username"] as! String
                    let highScore = document.data()["high_score"] as! Int
                    // Append the entry to leaderboardEntries managed by our leaderboardManager
                    self.leaderboardEntries.append(LeaderboardEntry(userEmail: document.documentID, username: username, highScore: highScore))
                }
            }
        }
    }
}
