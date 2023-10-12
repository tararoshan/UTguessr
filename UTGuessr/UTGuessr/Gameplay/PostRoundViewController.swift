//
//  PostRoundViewController.swift
//  UTGuessr
//
//  Created by Teresa Luo on 10/12/23.
//

import UIKit

class PostRoundViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    var score:String = ""
    
    let segueToGameIdentifier = "PostRoundToGame"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true)
        self.scoreLabel.text = score
    }

    @IBAction func nextRoundPressed(_ sender: Any) {
        // Segue back to the Game View Controller
        self.navigationController!.popViewController(animated: true)
    }
}