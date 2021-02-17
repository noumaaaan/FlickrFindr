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
    var temp: String?
    var page: Int = 1
    var totalPages: Int?
    var isFetching = false
    
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

    override func viewDidLoad() {
        formatInputs(text: searchTextField, button: searchButton)
        collectionView.delegate = self
        collectionView.dataSource = self
        self.urls = [String]()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func searchButtonTapped(_ sender: Any) {
        // Do nothing if nothing is searched
        if (searchTextField.text!.isReallyEmpty){
            return
            
        // If search term is same as previous, do nothing
        } else if (searchTextField.text == temp){
            return
            
        // if the urls array is not empty, clear the view then search
        } else {
            if (!urls!.isEmpty){
                urls!.removeAll()
                self.collectionView.reloadData()
            }
            temp = searchTextField.text
            self.getResponse(tags: searchTextField.text!, pageParam: 1)
        }
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
        button.layer.borderWidth = 1
    }
    
    // Function to get all images for a given search
    func getResponse(tags: String, pageParam: Int){
        isFetching = true
        let formatted = tags.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "+").replacingOccurrences(of: ",", with: "%2C+")
        
        var url = config.searchUrl + config.apiKey + "&tags=" + formatted + config.endUrl
        if (pageParam != 1){
            let newPage = String(self.page)
            url = config.searchUrl + config.apiKey + "&tags=" + formatted + "&page=" + newPage + config.endUrl
        }
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
            if let error = error {
                print(error)
                return
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(Response.self, from: data)
                    if (result.stat == "ok"){
                        if (result.photos!.photo.count > 1){
                            self.isFetching = true
                            for urls in result.photos!.photo {
                                DispatchQueue.main.async {
                                    GetImageInfo().getURLImages(photoId: urls.id) { [weak self] imageURLs in
                                        guard let self = self else { return }
                                        self.urls?.append(imageURLs)
                                        self.collectionView.reloadData()
                                    }
                                }
                            }
                            self.isFetching = false
                        } else {
                            DispatchQueue.main.async {
                                self.displayAlertMessage(userTitle: "Error", userMessage: "No results found for: " + tags, alertAction: "Return")
                                return
                            }
                        }
                    } else {
                        print(result)
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
            let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
            let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
            return CGSize(width: size, height: size)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isFetching == false else {
            return
        }
        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            self.getResponse(tags: searchTextField.text!, pageParam: page + 1)
        }
    }
    
    // Function to display an alert message parameters for the title, message and action type
    func displayAlertMessage(userTitle: String, userMessage:String, alertAction:String){
        let theAlert = UIAlertController(title: userTitle, message: userMessage, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: alertAction, style:UIAlertAction.Style.default, handler: nil)
        theAlert.addAction(okAction)
        self.present(theAlert, animated: true, completion: nil)
    }
    
    // Minimise keyboard on return
    @IBAction func returnTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
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

// https://stackoverflow.com/questions/37533058/how-to-check-if-a-textfieldview-is-empty-or-has-no-spaces
extension String {
    var isReallyEmpty: Bool {
        return self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
