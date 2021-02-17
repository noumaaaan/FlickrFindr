//
//  GetImageInfoViewController.swift
//  FlickrFinder
//
//  Created by Nouman Mehmood on 15/02/2021.
//

import UIKit

class GetImageInfo {
    
    struct Response: Codable {
        var sizes: sizeInfo?
    }
    struct sizeInfo: Codable {
        var size: [ImageUrls]
    }
    struct ImageUrls: Codable {
        var label: String
        var source: String
    }
    
    let config = AppConfig()
    
    // Function to return the URL for the searched images
    func getURLImages(photoId: String, completion: @escaping (String) -> Void) {
        let url = config.getImageInfo + config.apiKey + "&photo_id=" + photoId + config.endUrl
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
            if let error = error {
                print(error)
                return
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(Response.self, from: data)
                    for item in result.sizes!.size {
                        DispatchQueue.main.async {
                            if (item.label == "Large Square"){
                                completion(item.source)
                            }
                        }
                    }
                    
                } catch {
                    print(error)
                }
            }
        })
        task.resume()
    }
}
