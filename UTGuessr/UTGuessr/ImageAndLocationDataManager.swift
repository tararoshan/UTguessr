//
//  CacheManager.swift
//  UTGuessr
//
//  Created by Teresa Luo on 12/4/23.
//

import Foundation
import FirebaseFirestore
import CoreLocation

// Allows management of the images and locations between Firebase Firestore and local cache
class ImageAndLocationDataManager {
    static let shared = ImageAndLocationDataManager()
    
    private let db = Firestore.firestore()
    private let cache = NSCache<NSString, NSArray>()
    
    // Cache key
    private let imagesAndLocationsCacheKey = "images_and_locations"
    
    private init() {}
    
    func preFetchData(completion: @escaping (Result<[ImageAndLocation], Error>) -> Void) {
        // Check if items are already in the cache
        if let cachedItems = cache.object(forKey: imagesAndLocationsCacheKey as NSString) as? [ImageAndLocation] {
            completion(.success(cachedItems))
            return
        }
        
        // If not in the cache, fetch items from Firestore
        db.collection("images_and_locations").getDocuments() {
            (querySnapshot, err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            
            var items: [ImageAndLocation] = []
            
            for document in querySnapshot!.documents {
                let imageData = document.data()["image"]! as! Data
                let latitude = document.data()["latitude"]! as! Double
                let longitude = document.data()["longitude"]! as! Double
                
                let imageAndLocation = ImageAndLocation(image: UIImage(data: imageData)!, location: CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)))
                
                items.append(imageAndLocation)
            }
            
            // Cache the items locally
            self.cache.setObject(items as NSArray, forKey: self.imagesAndLocationsCacheKey as NSString)
            
            completion(.success(items))
        }
    }
    
    // Retrieve all images and locations from the cache
    func readFromCache() -> [ImageAndLocation] {
        return (cache.object(forKey: imagesAndLocationsCacheKey as NSString) as? [ImageAndLocation])!
    }
    
    // Gets a number of random images and locations from the cache
    func getRandomImagesAndLocations(number: Int) -> [ImageAndLocation] {
        // Get the images and locations in the local cache
        let imagesAndLocations = readFromCache()
        
        // Generate a number of random numbers
        let count = imagesAndLocations.count
        var imageIDs = Set<Int>()
        while imageIDs.count < number {
            imageIDs.insert(Int.random(in: 0..<count))
        }
        
        var result:[ImageAndLocation] = []
        for index in imageIDs {
            result.append(imagesAndLocations[index])
        }
        return result
    }
}
