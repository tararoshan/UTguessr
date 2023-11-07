//
//  GameViewController.swift
//  UTGuessr
//
//  Created by Alex Lu on 10/5/23.
//

import UIKit
import MapKit
import CoreLocation

class GameViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var gameMap: MKMapView!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    let userDefaults = UserDefaults.standard
    
    var userCoordinate: CLLocationCoordinate2D?
    var game:Game?
    var gameFinishedFetching = false {
        didSet {
            if gameFinishedFetching == true {
                print("GAME DONE POPULATING")
                // Set the image to the image from the current round
                self.image.image = self.game!.roundImagesAndLocations[self.game!.currentRound - 1].image
                
                // Enable the Confirm Pin button
                self.confirmButton.isEnabled = true
            }
        }
    }
    
    let segueToPostRoundIdentifier = "GameToPostRound"
    
    var newGame:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game = Game()
        game?.viewController = self
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if userDefaults.bool(forKey: "UTGuesserDarkMode") {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        // Remove any previous pins
        self.gameMap.removeAnnotations(self.gameMap.annotations)
        
        self.image.layer.cornerRadius = 15.0
        
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
        
        // Disable the Confirm Pin until the image has finished loading
        self.confirmButton.isEnabled = false
        
        if (gameFinishedFetching) {
            // Set the image to the image from the current round and enable the confirm buttom
            self.image.image = self.game!.roundImagesAndLocations[self.game!.currentRound - 1].image
            self.confirmButton.isEnabled = true
        }
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
            performSegue(withIdentifier: segueToPostRoundIdentifier, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Segueing to Post Round screen
        if (segue.identifier == segueToPostRoundIdentifier),
           let postRoundVC = segue.destination as? PostRoundViewController {
            postRoundVC.score = String(self.game!.roundScores[self.game!.currentRound - 2])
            postRoundVC.game = self.game!
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.image
    }
}
