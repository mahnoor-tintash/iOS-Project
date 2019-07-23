//
//  NetworkLayer.swift
//  Football News
//
//  Created by Mahnoor Khan on 17/07/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

protocol NetworkEngine {}

extension NetworkEngine {
    // MARK: data fetching functions
     func addFirebaseObserver<T : Codable>(node : String, observerType : DataEventType, decodedData : @escaping (_  objects : [T]?) -> ()) {
        let ref : DatabaseReference = Database.database().reference()
        ref.child(node).observe(observerType, with: { (dataSnapshot) in
            if dataSnapshot.value != nil {
                if let jsonData = try? JSONSerialization.data(withJSONObject: dataSnapshot.value as Any) {
                    print(jsonData)
                    do {
                        let objects : [T] = try JSONDecoder().decode([T].self, from: (jsonData))
                        decodedData(objects)
                    } catch {
                        print(error)
                    }
                }
            }
        }, withCancel: {Error in
            print (Error)
            // pass through to appropriate class and show user prompt
        })
    }
    
    // MARK: image downloading and caching functions
    func downloadImage(imageUrl : URL, image : @escaping (_ image : UIImage)->()) {
        let dataTask = URLSession.shared.dataTask(with: imageUrl) { (data, response, error ) in
            var downloadedImage : UIImage?
            if let data = data {
                downloadedImage = UIImage(data: data)
            }
            if let image = downloadedImage {
                FNCacheManager.shared.imageCache.setObject(image, forKey: imageUrl.absoluteString as NSString)
            }
            DispatchQueue.main.async {
                image(downloadedImage ?? UIImage(named: "football")!)
            }
        }
        dataTask.resume()
    }
    
    func getImage(imageUrl : URL, image : @escaping (_ image : UIImage)->()) {
        if let cachedImage = FNCacheManager.shared.imageCache.object(forKey: imageUrl.absoluteString as NSString) {
            image(cachedImage)
        }
        else {
            downloadImage(imageUrl: imageUrl, image: image)
        }
    }
}
