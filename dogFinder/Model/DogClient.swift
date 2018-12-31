//
//  DogClient.swift
//  dogFinder
//
//  Created by Frank Aceves on 10/1/18.
//  Copyright © 2018 Frank Aceves. All rights reserved.
//

import UIKit

class DogClient: NSObject {
    var dogURLArray: [URL] = []
    
    func showRandomDog(completionForShowRandomDog: @escaping (_ image: UIImage?, _ imageData: Data?,_ urlString: String?, _ error: String?) -> Void) {
        
        let randomDogURL = URL(string: FlickrConstants.APIUrls.urlString)!
        
        var dogPhoto = UIImage()
        let request = URLRequest(url: randomDogURL)
        
        taskForGetMethod(urlRequest: request) { (randomDogData, error) in
            guard (error == nil) else {
                completionForShowRandomDog(nil, nil, nil, "error in taskForGet: \(error!)")
                return
            }
            
            guard (randomDogData != nil) else {
                completionForShowRandomDog(nil, nil, nil, "no dog data from taskForGet")
                return
            }
            
            //update to pull a random page, photo, url
            let randomDogURLString = randomDogData.photos.photo[2].url_l ?? ""
            
            if let randomDogURL = URL(string: randomDogURLString), let dogData = try? Data(contentsOf: randomDogURL) {
                if let dogImage = UIImage(data: dogData) {
                    dogPhoto = dogImage
                    completionForShowRandomDog(dogPhoto, dogData, randomDogURLString, nil)
                } else {
                    completionForShowRandomDog(nil, nil, nil, "no image present")
                }
                
            }
            
            }.resume()
        
    }
    
    func taskForGetMethod(urlRequest: URLRequest, completionForGet: @escaping (_ result: FlickrConstants.Photos?, _ error: String?) -> Void) -> URLSessionDataTask{
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard (error == nil) else {
                completionForGet(nil, "there was an error: \(error!.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completionForGet(nil, "no status code returned")
                return
            }
            
            if statusCode < 200 {
                completionForGet(nil, "Status code was not lower than 200: \(statusCode)")
                return
            }
            
            guard let data = data else {
                completionForGet(nil, "no data returned")
                return
            }
            
            self.convertToJSONFrom(randomDogData: data, completionForJSONConversion: completionForGet)
            
        }
        return task
    } // TASK FOR GET METHOD
    
    func convertToJSONFrom(randomDogData: Data, completionForJSONConversion: @escaping (_ result: FlickrConstants.Photos?, _ error: String?) -> Void) {
        var decodedResults: FlickrConstants.Photos!
        
        do {
            decodedResults = try JSONDecoder().decode(FlickrConstants.Photos.self, from: randomDogData)
            print("decoded JSON")
            completionForJSONConversion(decodedResults, nil)
        } catch {
            print("error decoding Flickr JSON: \(error.localizedDescription)")
            completionForJSONConversion(nil, error.localizedDescription)
        }
    } // CONVERT TO JSON
    
    
    // Get breed info from dog photo URL
    func getBreedAndSubBreed(urlString: String) -> [String] {
        var stringArray = [String]()
        var breed: String!
        var subBreed: String!
        
        var fullBreed = urlString.replacingOccurrences(of: "https://images.dog.ceo/breeds/", with: "").capitalized
        if let slashIndex = fullBreed.index(of: "/") {
            fullBreed = String(fullBreed[..<slashIndex])
        }
        
        
        let splitDogBreed = fullBreed.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true)
        if splitDogBreed.count <= 1 {
            let breed = String(splitDogBreed[0])
            stringArray.append(breed)
        } else {
            breed = String(splitDogBreed[0])
            subBreed = String(splitDogBreed[1])
            stringArray.append(breed)
            stringArray.append(subBreed)
        }
        
        return stringArray
    } // GET BREED & SUBBREED
    
    // - MARK: SINGLETON
    static let sharedInstance = DogClient()
}
