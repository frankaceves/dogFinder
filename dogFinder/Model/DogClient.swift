//
//  DogClient.swift
//  dogFinder
//
//  Created by Frank Aceves on 10/1/18.
//  Copyright © 2018 Frank Aceves. All rights reserved.
//

import UIKit

class DogClient: NSObject {
    
    
    func showRandomDog(completionForShowRandomDog: @escaping (_ image: UIImage?,_ urlString: String?, _ error: String?) -> Void) {
        //print("showRandomDog called")
        let randomDogURL = URL(string: Constants.APIUrls.randomDogAPIString)!
        
        var dogPhoto = UIImage()
        let request = URLRequest(url: randomDogURL)
        
        taskForGetMethod(urlRequest: request) { (randomDogData, error) in
            guard (error == nil) else {
                //print("error in taskForGet: \(error!)")
                completionForShowRandomDog(nil, nil, "error in taskForGet: \(error!)")
                return
            }
            
            guard let randomDogData = randomDogData else {
                //print("no dog data from taskForGet")
                completionForShowRandomDog(nil, nil, "no dog data from taskForGet")
                return
            }
            
            let randomDogURLString = randomDogData.message
            
            if let randomDogURL = URL(string: randomDogURLString), let dogData = try? Data(contentsOf: randomDogURL) {
                if let dogImage = UIImage(data: dogData) {
                    dogPhoto = dogImage
                    //print("downloaded dog imageurl: \(randomDogURL)")
                    completionForShowRandomDog(dogPhoto, randomDogURLString, nil)
                } else {
                    completionForShowRandomDog(nil, nil, "no image present")
                }
                
            }
            
            }.resume()
        
    }
    
    func taskForGetMethod(urlRequest: URLRequest, completionForGet: @escaping (_ result: Constants.RandomDog?, _ error: String?) -> Void) -> URLSessionDataTask{
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard (error == nil) else {
                //print("there was an error: \(error!.localizedDescription)")
                completionForGet(nil, "there was an error: \(error!.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                //print("status code was not 200 or lower")
                completionForGet(nil, "no status code returned")
                return
            }
            
            if statusCode < 200 {
                completionForGet(nil, "Status code was not lower than 200: \(statusCode)")
                return
            }
            
            guard let data = data else {
                //print("no data returned")
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
            print("error decoding randomDog JSON: \(error.localizedDescription)")
            completionForJSONConversion(nil, error.localizedDescription)
        }
    } // CONVERT TO JSON
    
    
    // Get breed info from dog photo URL
    func getBreedAndSubBreed(urlString: String) -> [String] {
        //print("get breed from this url: \(urlString)")
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
    
    // GET DOG IMAGE/DATA
    func getDogDataFrom(dogImageUrl: String, completionForGetDogData: @escaping (_ imageData: Data?, _ error: String?) -> Void) {
        print("getDogData called")
        let dogURL = URL(string: dogImageUrl)!
        
        if let dogData = try? Data(contentsOf: dogURL) {
            print("dogData: \(dogData)")
            completionForGetDogData(dogData, nil)
        } else {
            print("can't access dogData inside GetDogData func")
            completionForGetDogData(nil, "can't access dogData inside GetDogData func")
        }
        
    }
    
    // - MARK: SINGLETON
    static let sharedInstance = DogClient()
}
