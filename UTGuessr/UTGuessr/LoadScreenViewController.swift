//
//  LoadScreenViewController.swift
//  UTGuessr
//
//  Created by Alex Lu on 11/3/23.
//

import UIKit
import FirebaseStorage

class LoadScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            await appLoad()
            
            
        }
        
        
        
    }
    func appLoad() async{
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let tempIMG = storageRef.child("catslol.gif")
        let imageRef = storageRef.child("images")
        let tempImg = imageRef.child("0000.jpeg")
        let numberOfItems:Int?
        print("----------------------")
        var firebaseFiles:[StorageReference] = []
        
        let dg = DispatchGroup()
        dg.enter()
        getLocalImageCount(dg: dg)
        dg.enter()
        imageRef.listAll() {(result, error) in
                if let error = error {
                    print(error.localizedDescription.description)
                    return
                }
                if let result = result {
                    firebaseFiles = result.items
                }
                dg.leave()
            }
            
            dg.notify(queue: .main) {
                print(firebaseFiles)
                print("DONE!@#!@#!@#!@#!@#")
                self.performSegue(withIdentifier: "LoadingDone", sender: nil)
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
    func getLocalImageCount(dg: DispatchGroup) -> Int {
        do {
            let dr = try FileManager.default.url(for: .applicationDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            print(dr.path())
            return 0
        } catch{
            print(error)
        }
        dg.leave()
        return -1
    }
}
