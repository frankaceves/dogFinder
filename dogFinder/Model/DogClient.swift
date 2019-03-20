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
    
    func showRandomDog(completionForShowRandomDog: @escaping (_ image: UIImage?, _ imageData: Data?,_ urlString: String?, _ error: String?, _ attributionString: String?) -> Void) {
        
        var dogPhoto = UIImage()
        
            // CREATE RANDOM PAGE
            let maxFlickrResults = 4000
            let resultsPerPage = FlickrConstants.APIUrls.resultsPerPage
            let maxPageNumber = (maxFlickrResults/resultsPerPage)
            
            //let randomPageNumber = Int(arc4random_uniform(UInt32(maxPageNumber)))
            let randomPageNumber = Int.random(in: 1...maxPageNumber)
            print("randompage: \(randomPageNumber)")
            
            // TODO: CALL FUNC THAT EXECUTES SECOND NETWORK REQUEST WITH PAGE NUMBER
            self.searchForRandomDogUsing(pageNumber: randomPageNumber, url: FlickrConstants.APIUrls.urlString, completionForSearchForRandomDog: { (urlArray, photoArray, error) in
                guard (error == nil) else {
                    completionForShowRandomDog(nil, nil, nil, "there was an error", nil)
                    return
                }
                
                guard let urlArray = urlArray else {
                    completionForShowRandomDog(nil, nil, nil, "error: no array present", nil)
                    return
                }
                
                guard let photoArray = photoArray else {
                    completionForShowRandomDog(nil, nil, nil, "error: no photo Array present", nil)
                    return
                }
                
                //self.dogURLArray = urlArray
                //print("dogURLArray = \(self.dogURLArray)")
                //self.dogURLArray.shuffle()
                //print("dogURLArray shuffled = \(self.dogURLArray)")
                
                //need to pick URL from a random photo from PhotoArray
                var shuffledPhotoArray = photoArray.shuffled()
                let dogToUse = shuffledPhotoArray[0]
                //print("dogToUse: \(dogToUse)")
                
                
                let attribution = self.getOwnerInfoFrom(id: dogToUse.id!)
                
                
                if let dogData = try? Data(contentsOf: (URL(string: dogToUse.url_m!)!)), let dogImage = UIImage(data: dogData) {
                    dogPhoto = dogImage
                    let urlString = dogToUse.url_m!
                    print("urlString used: \(urlString)")
                    print(attribution)
                    self.dogURLArray.removeAll()
                    completionForShowRandomDog(dogPhoto, dogData, urlString, nil, attribution)
                } else {
                    self.dogURLArray.removeAll()
                    completionForShowRandomDog(nil, nil, nil, "no image present", nil)
                }
            })
    }
    
    // FUNC - get list of URL's for random page of phtoos
    func searchForRandomDogUsing(pageNumber: Int, url: String, completionForSearchForRandomDog: @escaping (_ urlArray: [URL]?, _ error: String?) -> Void){
        
        let urlString = url.appending("&page=\(pageNumber)")
        let dogURL = URL(string: urlString)!
        var urlArray = [URL]()
        
        //print("SEARCH FOR RANDOM - randomDogURL: \(dogURL)")
        
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
                if let mediumUrlString = photo.url_m, let mediumURL = URL(string: mediumUrlString)  {
                    //print("SEARCH FOR RANDOM: using largeURL")
                    if photo.height_m! > photo.width_m! {
                        urlArray.append(mediumURL)
                        //print("added url: \(mediumURL)")
                    }
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
    
    
    // - MARK: SINGLETON
    static let sharedInstance = DogClient()
}
