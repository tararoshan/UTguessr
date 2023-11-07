//
//  LoadScreenViewController.swift
//  UTGuessr
//
//  Created by Alex Lu on 11/3/23.
//

import UIKit

class LoadScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.performSegue(withIdentifier: "LoadingDone", sender: nil)
    }
}
