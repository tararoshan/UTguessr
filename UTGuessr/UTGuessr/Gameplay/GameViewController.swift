//
//  GameViewController.swift
//  UTGuessr
//
//  Created by Alex Lu on 10/5/23.
//

import UIKit
import MapKit
import CoreLocation

class GameViewController: UIViewController {

    @IBOutlet weak var gameMap: MKMapView!
    var userCoordinate: CLLocationCoordinate2D?
    var game:Game?
    
    let segueToPostRoundIdentifier = "GameToPostRound"
    let segueToPostGameIdentifier = "GameToPostGame"
    
    var newGame:Bool = true
    
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game = Game()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: true)
        // Remove any previous pins
        self.gameMap.removeAnnotations(self.gameMap.annotations)
        self.image.layer.cornerRadius = 8.0
        
        // Log the round
        print("Current round:", self.game!.currentRound)
        
        // Define the upper left and lower right corners of the initial Map View
        let corner1 = MKMapPoint(CLLocationCoordinate2DMake(30.293307, -97.741870))
        let corner2 = MKMapPoint(CLLocationCoordinate2DMake(30.278481, -97.729006))

        // Make a MKMapRect using mins and spans
        let mapRect = MKMapRect(
            x: corner1.x,
            y: corner1.y,
            width: fabs(corner1.x - corner2.x),
            height: fabs(corner1.y - corner2.y))
        
        gameMap.setVisibleMapRect(mapRect, animated: false)
        gameMap.pointOfInterestFilter = .excludingAll
        
        // Add gesture recognizer
        let tapPress = UITapGestureRecognizer(target: self, action: #selector(self.mapTapPress(_:)))
        gameMap.addGestureRecognizer(tapPress)
        
        // TODO: Set the image to the image from the current round
    }
    
    @objc func mapTapPress(_ recognizer: UIGestureRecognizer) {
        // Remove any previous pins
        self.gameMap.removeAnnotations(self.gameMap.annotations)

        let touchedAt = recognizer.location(in: self.gameMap)
        let touchedAtCoordinate: CLLocationCoordinate2D = gameMap.convert(touchedAt, toCoordinateFrom: self.gameMap)
        let newPin = MKPointAnnotation()
        newPin.coordinate = touchedAtCoordinate
        gameMap.addAnnotation(newPin)
        
        self.userCoordinate = touchedAtCoordinate
        
        print("User tapped", touchedAtCoordinate.latitude, touchedAtCoordinate.longitude)
    }
    
    @IBAction func confirmPinButtonPressed(_ sender: Any) {
        
        if (self.userCoordinate != nil) {
            self.game!.finishRound(userCoordinate: self.userCoordinate!)
            if self.game!.isOver() {
                performSegue(withIdentifier: segueToPostGameIdentifier, sender: nil)
            } else {
                // Game not over, segue to Post Round View Controller
                performSegue(withIdentifier: segueToPostRoundIdentifier, sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Segueing to Post Round screen
        if (segue.identifier == segueToPostRoundIdentifier),
           let postRoundVC = segue.destination as? PostRoundViewController {
            postRoundVC.score = String(self.game!.roundScores[self.game!.currentRound - 2])
        }
        
        // Segueing to Post Game screen
        if (segue.identifier == segueToPostGameIdentifier),
           let postGameVC = segue.destination as? PostGameViewController {
            postGameVC.score = String(self.game!.roundScores.reduce(0, +))
        }
    }
}
