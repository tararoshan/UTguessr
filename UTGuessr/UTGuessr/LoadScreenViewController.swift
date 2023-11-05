//
//  LoadScreenViewController.swift
//  UTGuessr
//
//  Created by Alex Lu on 11/3/23.
//

import UIKit
import FirebaseStorage

class LoadScreenViewController: UIViewController {
    let storage = Storage.storage()
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
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images")
        let userRef = storageRef.child("users")
        print("----------------------")
        var imageFiles:[StorageReference] = []
        var userFiles:[StorageReference] = []
        
        let dg = DispatchGroup()
        dg.enter()
        print("************LISTING ALL************")
        imageRef.listAll() {(result, error) in
                if let error = error {
                    print(error.localizedDescription.description)
                    return
                }
                if let result = result {
                    imageFiles = result.items
                    if result.items.count != self.checkImageFolder(){
                        self.loadImages()
                    } else {
                        print("images not loaded SAME IMAGES")
                    }
                }
                
                dg.leave()
            }
        
        userRef.listAll() {
            (result, error) in
            if let error = error {
                print(error.localizedDescription.description)
                return
            }
            if let result = result {
                userFiles = result.items
            }
        }
            
        dg.notify(queue: .main) {
            print(imageFiles)
            print("DONE!@#!@#!@#!@#!@#")
            dg.enter()
            
            dg.leave()
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
    func checkImageFolder() -> Int {
        print(NSHomeDirectory())
        do {
            //  get reference to document directory
            let dd = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let imageFolderPath = dd.appendingPathComponent("images")
            if FileManager.default.fileExists(atPath: imageFolderPath.path()){
                print("Image folder already exists")
            } else {
                print("Image folder does not exist")
                try FileManager.default.createDirectory(at: imageFolderPath, withIntermediateDirectories: false, attributes: nil)
                print("Image folder created")
                return 0
            }
            let fileUrls = try FileManager.default.contentsOfDirectory(at: imageFolderPath, includingPropertiesForKeys: nil)
            print("Documents", fileUrls.count)
            return fileUrls.count
        } catch{
            print(error)
        }
        return -1
    }
    
    func loadImages() {
        let storageRef = storage.reference()
        let fimageRef = storageRef.child("images") // firebase image folder reference
        do {
            let dd = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let imageFolderPath = dd.appendingPathComponent("images")
            let imageFiles = try FileManager.default.contentsOfDirectory(at: imageFolderPath, includingPropertiesForKeys: nil)
            
            for imageFile in imageFiles {
                try FileManager.default.removeItem(at: imageFile)
                print("Removed \(imageFile.lastPathComponent)")
            }
            fimageRef.listAll() {(result, error) in
                if let error = error {
                    print(error.localizedDescription.description)
                    return
                }
                for item in result!.items {
                    let localURL = imageFolderPath.appending(path: item.name)
                    let downloadTask = item.write(toFile: localURL) {
                        url, error in
                        if let error = error{
                            print(error)
                        } else {
                            print("Loaded \(item.name) to local storage")
                        }
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }

        
    }
}
