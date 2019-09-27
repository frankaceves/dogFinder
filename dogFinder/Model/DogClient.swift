//
//  DogClient.swift
//  dogFinder
//
//  Created by Frank Aceves on 10/1/18.
//  Copyright © 2018 Frank Aceves. All rights reserved.
//

import UIKit

class DogClient: NSObject {
    
    func showRandomDog(completionRandom: @escaping (_ dog: Dog?, _ error: String?) -> Void) {
        let randomDogURL = URL(string: Constants.APIUrls.randomDogAPIString)!
        let request = URLRequest(url: randomDogURL)
        
        taskForGetMethod(urlRequest: request) { (results, error) in
            guard error == nil else {
                completionRandom(nil, "error getting Dog: \(error!)")
                return
            }
            
            guard let results = results else {
                completionRandom(nil, "no results")
                return
            }
            
            var dog = Dog(urlString: results.message)
            dog.getBreedAndSubBreed()
            dog.getImageData(from: dog.urlString)
            //this info goes back to viewController, but should we only return the image?
            //should we create an imageModel, then from VC access the dog info?
            completionRandom(dog, nil)
            
        }.resume()
    }
    
    func getThreeRandomDogs(completion3RandomDogs: @escaping (_ dog: [Dog]?, _ error: String?) -> Void) {
        let randomDogURL = URL(string: Constants.APIUrls.threeDogAPIString)!
        let request = URLRequest(url: randomDogURL)
        
        let _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard (error == nil) else {
                completion3RandomDogs(nil, error!.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode < 299 else {
                completion3RandomDogs(nil, "Status code error 3randDogs, code not less than 299")
                return
            }
            
            guard let data = data else {
                completion3RandomDogs(nil, "no data returned in 3randDogs")
                return
            }
            
            //self.convertToJSONFrom(randomDogData: data, completionForJSONConversion: completionForGet)
            var decodedResults: Constants.ThreeRandomDogs
            var dogs: [Dog] = []
            
            do {
                decodedResults = try JSONDecoder().decode(Constants.ThreeRandomDogs.self, from: data)
                for result in decodedResults.message {
                    var dog = Dog(urlString: result)
                    dog.getBreedAndSubBreed()
                    dogs.append(dog)
                }
                completion3RandomDogs(dogs, nil)
            } catch {
                completion3RandomDogs(nil, "error in jsonconversion 3randDogs: \(error.localizedDescription)")
            }
            
        }.resume()
    }
    
    func showRandomDog(completionForShowRandomDog: @escaping (_ image: UIImage?, _ imageData: Data?,_ urlString: String?, _ error: String?) -> Void) {
        
        let randomDogURL = URL(string: Constants.APIUrls.randomDogAPIString)!
        var dogPhoto = UIImage()
        let request = URLRequest(url: randomDogURL)
        
        taskForGetMethod(urlRequest: request) { (randomDogData, error) in
            guard (error == nil) else {
                completionForShowRandomDog(nil, nil, nil, "error in taskForGet: \(error!)")
                return
            }
            
            guard let randomDogData = randomDogData else {
                completionForShowRandomDog(nil, nil, nil, "no dog data from taskForGet")
                return
            }
            
            let randomDogURLString = randomDogData.message
            
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
    
    func taskForGetMethod(urlRequest: URLRequest, completionForGet: @escaping (_ result: Constants.RandomDog?, _ error: String?) -> Void) -> URLSessionDataTask{
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard (error == nil) else {
                completionForGet(nil, "there was an error: \(error!.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode < 299 else {
                completionForGet(nil, "Status code error")
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
    
    func convertToJSONFrom(randomDogData: Data, completionForJSONConversion: @escaping (_ result: Constants.RandomDog?, _ error: String?) -> Void) {
        var decodedResults: Constants.RandomDog!
        
        do {
            decodedResults = try JSONDecoder().decode(Constants.RandomDog.self, from: randomDogData)
            completionForJSONConversion(decodedResults, nil)
        } catch {
            completionForJSONConversion(nil, error.localizedDescription)
        }
    } // CONVERT TO JSON
    
    
    // Get breed info from dog photo URL
    func getBreedAndSubBreed(urlString: String) -> [String] {
        var stringArray = [String]()
        var breed: String!
        var subBreed: String!
        
        var fullBreed = urlString.replacingOccurrences(of: "https://images.dog.ceo/breeds/", with: "").capitalized
        if let slashIndex = fullBreed.firstIndex(of: "/") {
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
