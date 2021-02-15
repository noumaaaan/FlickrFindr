//
//  ViewController.swift
//  FlickrFinder
//
//  Created by Nouman Mehmood on 13/02/2021.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBAction func textFieldPrimaryActionTriggered(_ sender: Any) {
        print(searchTextField.text!)
        self.getResponse(tags: searchTextField.text!)
    }
    
    let config = AppConfig()
    
    struct Response: Codable {
        let photos : PagedImageResult?
        let stat: String
    }
    struct PagedImageResult: Codable {
        let photo : [FlickrURLs]
        let page: Int
        let pages: Int
        let perpage: Int
        let total: String
    }
    struct FlickrURLs: Codable {
        let id : String
    }
    
    private func getResponse(tags: String){
        let formatted = tags.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "%2C")
        let url = config.baseUrl + config.searchUrl + config.apiKey + "&tags=" + formatted + config.endUrl
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
            if let error = error {
                print(error)
                return
            } else if let data = data {
                do {
                    let flickrPhotos = try JSONDecoder().decode(Response.self, from: data)
                    print(flickrPhotos)
                } catch {
                    print(error)
                }
            }
        })
        task.resume()
    }

}



