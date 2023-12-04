//
//  GameViewController.swift
//  UTGuessr
//
//  Created by Alex Lu on 10/5/23.
//

import UIKit
import MapKit
import CoreLocation
import AVFAudio

class GameViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var gameMap: MKMapView!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    let userDefaults = UserDefaults.standard
    var audioPlayer:AVAudioPlayer?
    
    var userCoordinate: CLLocationCoordinate2D?
    var game:Game?
    
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
        
        let displaySetting = userDefaults.integer(forKey: "UTGuesserDarkMode")
        if displaySetting == displayTypeEnum.system.rawValue {
            overrideUserInterfaceStyle = .unspecified
        } else if displaySetting == displayTypeEnum.dark.rawValue {
            overrideUserInterfaceStyle = .dark
        } else if displaySetting == displayTypeEnum.light.rawValue{
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
        
        // Set the image
        self.image.image = self.game!.roundImagesAndLocations[self.game!.currentRound - 1].image
    }
    
    @objc func mapTapPress(_ recognizer: UIGestureRecognizer) {
        if !self.userDefaults.bool(forKey: "UTGuesserSoundOff") {
            let path = Bundle.main.path(forResource: "pin-drop.mp3", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer!.play()
            } catch {
                print("Couldn't load sound effect.")
            }
        }
        
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

            if !self.userDefaults.bool(forKey: "UTGuesserSoundOff") {
                let path = Bundle.main.path(forResource: "click.mp3", ofType: nil)!
                let url = URL(fileURLWithPath: path)
                
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer!.play()
                } catch {
                    print("Couldn't load sound effect.")
                }
            }
                
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
