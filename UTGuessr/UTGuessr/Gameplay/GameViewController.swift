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

    @IBOutlet weak var confirmView: UIScrollView!
    @IBOutlet weak var gameMap: MKMapView!
    var cord: CLLocationCoordinate2D?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // these are your two lat/long coordinates
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let coordinate1 = CLLocationCoordinate2DMake(30.278481, -97.729006)
        let coordinate2 = CLLocationCoordinate2DMake(30.293307, -97.741870)

        // convert them to MKMapPoint
        let p1 = MKMapPoint (coordinate1)
        let p2 = MKMapPoint (coordinate2)

        // and make a MKMapRect using mins and spans
        let mapRect = MKMapRect(x: fmin(p1.x,p2.x), y: fmin(p1.y,p2.y), width: fabs(p1.x-p2.x), height: fabs(p1.y-p2.y))
        gameMap.setVisibleMapRect(mapRect, animated: false)
        // Do any additional setup after loading the view.
        
        // add gesture recognizer
        let tapPress = UITapGestureRecognizer(target: self, action: #selector(self.mapTapPress(_:))) // colon needs to pass through info
        gameMap.addGestureRecognizer(tapPress)
    }
    
    @objc func mapTapPress(_ recognizer: UIGestureRecognizer){
        self.gameMap.removeAnnotations(self.gameMap.annotations)
        print("A tap has been detected.")

        let touchedAt = recognizer.location(in: self.gameMap) // adds the location on the view it was pressed
        let touchedAtCoordinate : CLLocationCoordinate2D = gameMap.convert(touchedAt, toCoordinateFrom: self.gameMap) // will get coordinates
        let newPin = MKPointAnnotation()
        newPin.coordinate = touchedAtCoordinate
        gameMap.addAnnotation(newPin)
        self.cord = gameMap.annotations.first?.coordinate
        print(cord!.latitude,cord!.longitude)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
