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
    var game:Game = Game()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Define the upper left and lower right corners of the initial Map View
        let corner1 = MKMapPoint(CLLocationCoordinate2DMake(30.278481, -97.729006))
        let corner2 = MKMapPoint(CLLocationCoordinate2DMake(30.293307, -97.741870))

        // Make a MKMapRect using mins and spans
        let mapRect = MKMapRect(
            x: corner1.x,
            y: corner1.y,
            width: fabs(corner1.x - corner2.x),
            height: fabs(corner1.y - corner2.y))
        
        gameMap.setVisibleMapRect(mapRect, animated: false)
        
        // Add gesture recognizer
        let tapPress = UITapGestureRecognizer(target: self, action: #selector(self.mapTapPress(_:)))
        gameMap.addGestureRecognizer(tapPress)
    }
    
    @objc func mapTapPress(_ recognizer: UIGestureRecognizer) {
        // Remove any previous pins
        self.gameMap.removeAnnotations(self.gameMap.annotations)

        let touchedAt = recognizer.location(in: self.gameMap)
        let touchedAtCoordinate : CLLocationCoordinate2D = gameMap.convert(touchedAt, toCoordinateFrom: self.gameMap)
        let newPin = MKPointAnnotation()
        newPin.coordinate = touchedAtCoordinate
        gameMap.addAnnotation(newPin)
        
        self.userCoordinate = gameMap.annotations.first?.coordinate
        print("User tapped", userCoordinate!.latitude,userCoordinate!.longitude)
        
    }
}
