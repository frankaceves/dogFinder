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
            
            // CREATE RANDOM PAGE
            let maxFlickrResults = 4000
            let resultsPerPage = FlickrConstants.APIUrls.resultsPerPage
            let maxPageNumber = (maxFlickrResults/resultsPerPage)
            
            let randomPageNumber = Int(arc4random_uniform(UInt32(maxPageNumber)))
            
            
            // TODO: CALL FUNC THAT EXECUTES SECOND NETWORK REQUEST WITH PAGE NUMBER
            self.searchForRandomDogUsing(pageNumber: randomPageNumber, url: FlickrConstants.APIUrls.urlString, completionForSearchForRandomDog: { (urlArray, error) in
                guard (error == nil) else {
                    completionForShowRandomDog(nil, nil, nil, "there was an error")
                    return
                }
                
                guard let urlArray = urlArray else {
                    completionForShowRandomDog(nil, nil, nil, "error: no array present")
                    return
                }
                
                //print("SHOW RANDOM DOG>SEARCHRANDOM - urls = \(urlArray)")
                self.dogURLArray = urlArray
                //print("dogURLArray = \(self.dogURLArray)")
                self.dogURLArray.shuffle()
                //print("dogURLArray shuffled = \(self.dogURLArray)")
                
                
                
                if let dogData = try? Data(contentsOf: self.dogURLArray[0]), let dogImage = UIImage(data: dogData) {
                    dogPhoto = dogImage
                    let urlString = self.dogURLArray[0].absoluteString
                    self.dogURLArray.removeAll()
                    completionForShowRandomDog(dogPhoto, dogData, urlString, nil)
                } else {
                    self.dogURLArray.removeAll()
                    completionForShowRandomDog(nil, nil, nil, "no image present")
                }
            })
            
            }.resume()
        
    }
    
    // FUNC - get list of URL's for random page of phtoos
    func searchForRandomDogUsing(pageNumber: Int, url: String, completionForSearchForRandomDog: @escaping (_ urlArray: [URL]?, _ error: String?) -> Void){
        
        let urlString = url.appending("&page=\(pageNumber)")
        let dogURL = URL(string: urlString)!
        var urlArray = [URL]()
        
        print("SEARCH FOR RANDOM - randomDogURL: \(dogURL)")
        
        let request = URLRequest(url: dogURL)
        
        taskForGetMethod(urlRequest: request) { (photos, error) in
            //code
            guard (error == nil) else {
                print("SEARCH FOR RANDOM: error = \(error!)")
                return
            }
            
            guard let photoInfo = photos else {
                print("SEARCH FOR RANDOM: error downloading")
                return
            }
            
            //store array of Photos
            let photoArray = photoInfo.photos.photo
            for photo in photoArray {
                if let largeUrlString = photo.url_l, let largeURL = URL(string: largeUrlString)  {
                    //print("SEARCH FOR RANDOM: using largeURL")
                    urlArray.append(largeURL)
                    //print("added url: \(largeURL)")
                } else if let originalUrlString = photo.url_0, let originalURL = URL(string: originalUrlString) {
                    //print("SEARCH FOR RANDOM: using originalURL")
                    urlArray.append(originalURL)
                    //print("added url: \(originalURL)")
                } else {
                    //print("SEARCH FOR RANDOM: can't get url")
                }
            } // end iteration
            
            completionForSearchForRandomDog(urlArray, nil)
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
            //print("decoded JSON")
            completionForJSONConversion(decodedResults, nil)
        } catch {
            //print("error decoding Flickr JSON: \(error.localizedDescription)")
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
