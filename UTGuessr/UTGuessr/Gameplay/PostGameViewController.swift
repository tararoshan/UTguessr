//
//  PostGameViewController.swift
//  UTGuessr
//
//  Created by Teresa Luo on 10/12/23.
//

import UIKit

class PostGameViewController: UIViewController {
    
    let segueToCountdownIdentifier = "PostGameToCountdown"

    @IBOutlet weak var scoreLabel: UILabel!
    var score:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scoreLabel.text = score
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    @IBAction func playAgainPressed(_ sender: Any) {
        performSegue(withIdentifier: segueToCountdownIdentifier, sender: nil)
    }
}
