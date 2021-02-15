//
//  AppConfig.swift
//  FlickrFinder
//
//  Created by Nouman Mehmood on 15/02/2021.
//

import Foundation

struct AppConfig {
    let baseUrl = "https://api.flickr.com/services/rest/"
    let searchUrl = "?method=flickr.photos.search"
    let apiKey = "&api_key=f9cc014fa76b098f9e82f1c288379ea1"
    let endUrl = "&format=json&nojsoncallback=1"
}
