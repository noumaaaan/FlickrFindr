//
//  AppConfig.swift
//  FlickrFinder
//
//  Created by Nouman Mehmood on 15/02/2021.
//

import Foundation

struct AppConfig {
    let searchUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
    let getImageInfo = "https://api.flickr.com/services/rest/?method=flickr.photos.getSizes"
    let apiKey = "&api_key=f9cc014fa76b098f9e82f1c288379ea1"
    let endUrl = "&format=json&nojsoncallback=1"
}
