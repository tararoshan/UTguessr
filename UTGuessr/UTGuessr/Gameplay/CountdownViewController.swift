//
//  CountdownViewController.swift
//  UTGuessr
//
//  Created by Alex Lu on 10/5/23.
//

import UIKit

class CountdownViewController: UIViewController {
    
    var sysTimer = Timer()
    let segueToGameIdentifier = "CountdownToGame"
    
    @IBOutlet weak var timer: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: true)
        sysTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
    }
    
    @objc func countDown(){
        timer.text = String(Int(timer.text!)! - 1)
        if Int(timer.text!)! <= 0 {
            performSegue(withIdentifier: segueToGameIdentifier, sender: nil)
            sysTimer.invalidate()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let gameViewController = segue.destination as? GameViewController {
            gameViewController.modalPresentationStyle = .fullScreen
        }
    }
}
