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
            self.performSegue(withIdentifier: "LoadingDone", sender: nil)
        }
        
    }
    func appLoad() async {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let tempIMG = storageRef.child("catslol.gif")
        let imageRef = storageRef.child("images")
        let tempImg = imageRef.child("0000.jpeg")
        print("----------------------")
        let getFileNames = Task { () -> [StorageReference] in
            var firebaseFiles:[StorageReference] = []
            imageRef.listAll {(result, error) in
                if let error = error {
                    return
                }
                for item in result!.items{
                    firebaseFiles.append(item)
                    print(item)
                }}
            return firebaseFiles
        }
        let result = await getFileNames.result
        do {
            let list = try result.get()
            print(list)
        } catch {
            print("error")
        }
        return
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
