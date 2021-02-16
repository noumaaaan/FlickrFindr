//
//  ViewController.swift
//  FlickrFinder
//
//  Created by Nouman Mehmood on 13/02/2021.
//

import UIKit
import SDWebImage

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Storyboard outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    let config = AppConfig()
    let getInfo = GetImageInfo()
    var urls: [String]?
    
    override func viewDidLoad() {
        formatInputs(text: searchTextField, button: searchButton)
        self.hideKeyboardWhenTappedAround()
        collectionView.delegate = self
        collectionView.dataSource = self
        self.urls = [String]()
    }
    
    // Get response when search button pressed
    @IBAction func searchButtonTapped(_ sender: Any) {
        self.collectionView.reloadData()
        self.getResponse(tags: searchTextField.text!)
    }
    
    // Minimise keyboard on return
    @IBAction func returnTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    // Format inputs
    func formatInputs(text: UITextField, button: UIButton){
        text.keyboardType = .alphabet
        text.autocorrectionType = .no
        text.backgroundColor = hexStringToUIColor(hex: "#fef5f1")
        text.textColor = hexStringToUIColor(hex: "#461220")
        button.backgroundColor = hexStringToUIColor(hex: "#b23a48")
        button.setTitleColor(hexStringToUIColor(hex: "#fed0bb"), for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(red:139/255.0, green:157/255.0, blue:195/255.0, alpha: 1.0).cgColor
    }
    
    // JSON STRUCT
    struct Response: Codable {
        let photos: PagedImageResult?
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
    
    // Function to get all images for a given search
    func getResponse(tags: String){
        let formatted = tags.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "%2C+")
        let url = config.searchUrl + config.apiKey + "&tags=" + formatted + config.endUrl
        print(url)
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
            if let error = error {
                print(error)
                return
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(Response.self, from: data)
                    if (result.stat == "ok"){
                        for urls in result.photos!.photo {
                            DispatchQueue.main.async {
                                GetImageInfo().getURLImages(photoId: urls.id) { [weak self] imageURLs in
                                    guard let self = self else { return }
                                    self.urls?.append(imageURLs)
                                    self.collectionView.reloadData()
                                }
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        cell.imageView.image = nil
        cell.imageView.sd_setImage(with: URL(string: String(urls![indexPath.row])), placeholderImage: nil, options: [.progressiveLoad])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           let padding: CGFloat =  10
           let collectionViewSize = collectionView.frame.size.width - padding
           return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
    }
    
    // https://stackoverflow.com/questions/24263007/how-to-use-hex-color-values
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

// https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
