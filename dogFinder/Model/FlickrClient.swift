//
//  FlickrClient.swift
//  dogFinder
//
//  Created by Frank Aceves on 11/28/18.
//  Copyright © 2018 Frank Aceves. All rights reserved.
//
import Foundation

extension DogClient {
    struct FlickrConstants {
        struct Photos: Decodable {
            let photos: PhotoInfo
            let stat: String
        }
        
        struct PhotoInfo: Decodable {
            let page: Int
            let pages: Int
            let photo: [Photo]
        }
        
        struct Photo: Decodable {
            let url_l: String?
            let url_z: String?
            let url_0: String?
            let url_m: String?
            let height_m: String?
            let width_m: String?
        }
        
        
        //RANDOM DOG JSON
        struct APIUrls {
            static let apiKey = "ad57c918d7705a17a075a02858b94f59"
            static let resultsPerPage = 25
            
            static let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=puppy%2C+puppies&sort=relevance&content_type=1&media=photos&extras=license%2C+url_l%2C+url_z%2C+url_o%2C+url_m&format=json&nojsoncallback=1&per_page=\(resultsPerPage)"
        }
        
    }
}
