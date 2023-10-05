//
//  CountdownViewController.swift
//  UTGuessr
//
//  Created by Alex Lu on 10/5/23.
//

import UIKit

class CountdownViewController: UIViewController {
    var sysTimer = Timer()
    @IBOutlet weak var timer: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        sysTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
    }
    @objc func countDown(){
        timer.text = String(Int(timer.text!)!-1)
        if timer.text == "0" {
            sysTimer.invalidate()
        }
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
