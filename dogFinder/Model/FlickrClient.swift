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
            let id: String?
        }
        
        
        //RANDOM DOG JSON
        struct APIUrls {
            static let apiKey = "ad57c918d7705a17a075a02858b94f59"
            static let resultsPerPage = 25
            
            static let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=puppy%2C+puppies&sort=relevance&content_type=1&media=photos&extras=license%2C+url_l%2C+url_z%2C+url_o%2C+url_m&format=json&nojsoncallback=1&per_page=\(resultsPerPage)"
        }
    }
    
    func getOwnerInfoFrom(id: String) -> String {
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=ad57c918d7705a17a075a02858b94f59&photo_id=\(id)&format=json&nojsoncallback=1"
        
        let url = URL(string: urlString)!
        
        let data = try? Data(contentsOf: url)
        //print(data)
        
        var json: Result!
        
        do {
            json = try JSONDecoder().decode(Result.self, from: data!)
        } catch {
            print("error decoding: \(error.localizedDescription)")
        }
        
        let photoURL = json.photo.urls.url[0]._content
        let owner = json.photo.owner.username
        //print("Photo by: \(owner) on Flickr\nUrl: \(photoURL)")
        return "Photo by: \(owner) on Flickr\nUrl: \(photoURL)"
    }
}
