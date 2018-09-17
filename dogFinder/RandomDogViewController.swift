//
//  ViewController.swift
//  puppyFinder
//
//  Created by Frank Aceves on 9/3/18.
//  Copyright © 2018 Frank Aceves. All rights reserved.
//

import UIKit
import CoreData

class RandomDogViewController: UIViewController {
    
    @IBOutlet var randomDogImageView: UIImageView!
    @IBOutlet var reloadButton: UIBarButtonItem!
    @IBOutlet var breedLabel: UILabel!
    @IBOutlet weak var favoritesButton: UIBarButtonItem!
    
    var dataController: DataController!
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var favoriteDogs = [[String: String]]()
    var tempDog: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("viewDidLoad")
        breedLabel.isHidden = true
        favoritesButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("viewWillAppear RandomDogVC")
    }

    struct RandomDog: Decodable {
        let status: String
        let message: String
    }
    
    struct AllDogBreeds: Decodable {
        let status: String
        //let message: [Breed: [SubBreed]] // [breed: [subBreed]]
        let message: [String: [String]]
    }
    
    struct Breed: Decodable {
        let breed: String
    }
    
    struct SubBreed: Decodable {
        let subBreed: [String]
    }
    
    
    //RANDOM DOG JSON
    let randomDogAPIString = "https://dog.ceo/api/breeds/image/random"
    
    @IBAction func randomDogButtonPressed(_ sender: Any) {
        tempDog.removeAll()
        favoritesButton.tintColor = nil
        
        activityIndicator.color = UIColor.blue
        activityIndicator.frame = randomDogImageView.bounds
        randomDogImageView.addSubview(activityIndicator)
        randomDogImageView.alpha = 0.5
        activityIndicator.startAnimating()
        
        showRandomDog { (image, urlString, error) in
            guard error == nil else {
                print("there was an error: \(error!)")
                return
            }
            
            guard let urlString = urlString else {
                print("no dogURL string returned from showRandomDog")
                return
            }
            
            guard let image = image else {
                print("no photo returned")
                
                DispatchQueue.main.async {
                    self.randomDogImageView.image = #imageLiteral(resourceName: "shiba-8.JPG")
                    self.breedLabel.text = "No Photo Available"
                    self.breedLabel.isHidden = false
                    self.activityIndicator.stopAnimating()
                }
                
                return
            }
            
            let breedArray = self.getBreedAndSubBreed(urlString: urlString)
            
            DispatchQueue.main.async {
                self.randomDogImageView.image = image
                self.randomDogImageView.alpha = 1.0
                self.breedLabel.text = "Breed: \(breedArray[0])"
                self.breedLabel.isHidden = false
                self.favoritesButton.isEnabled = true
                self.activityIndicator.stopAnimating()
            }
            
            self.tempDog.updateValue(breedArray[0], forKey: urlString)
            //print("tempDog keys after image DL: \(self.tempDog)")
            
        }
    }
    
    @IBAction func favoritesButtonPressed(_ sender: Any) {
        //toggle tint
        //add tempDog to favoritesArray
        //clear tempDog
        if favoritesButton.tintColor == nil {
            favoritesButton.tintColor = UIColor.red
            //favoriteDogs.append(tempDog)
            FavoriteDogsTEMP.sharedInstance.favoriteDogs.append(tempDog)
            //tempDog.removeAll()
            print("***AFTER ADD***\nfavDogsCount: \(FavoriteDogsTEMP.sharedInstance.favoriteDogs.count)\nfavDogs: \(FavoriteDogsTEMP.sharedInstance.favoriteDogs)")
            print("tempDog: \(tempDog)")
        } else {
            favoritesButton.tintColor = nil
            //favoriteDogs.removeLast()
            FavoriteDogsTEMP.sharedInstance.favoriteDogs.removeLast()
            print("***AFTER REMOVE***\nfavDogsCount: \(FavoriteDogsTEMP.sharedInstance.favoriteDogs.count)\nfavDogs: \(FavoriteDogsTEMP.sharedInstance.favoriteDogs)")
            print("tempDog: \(tempDog)")
        }
    }
    
    func showRandomDog(completionForShowRandomDog: @escaping (_ image: UIImage?,_ urlString: String?, _ error: String?) -> Void) {
        //print("showRandomDog called")
        let randomDogURL = URL(string: randomDogAPIString)!
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
    
    func taskForGetMethod(urlRequest: URLRequest, completionForGet: @escaping (_ result: RandomDog?, _ error: String?) -> Void) -> URLSessionDataTask{
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard (error == nil) else {
                //print("there was an error: \(error!.localizedDescription)")
                completionForGet(nil, "there was an error: \(error!.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode <= 200 else {
                //print("status code was not 200 or lower")
                completionForGet(nil, "status code was not 200 or lower")
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
    }
    // convert data to JSON
    func convertToJSONFrom(randomDogData: Data, completionForJSONConversion: @escaping (_ result: RandomDog?, _ error: String?) -> Void) {
        var decodedResults: RandomDog!
        
        do {
            decodedResults = try JSONDecoder().decode(RandomDog.self, from: randomDogData)
            completionForJSONConversion(decodedResults, nil)
        } catch {
            print("error decoding randomDog JSON: \(error.localizedDescription)")
            completionForJSONConversion(nil, error.localizedDescription)
        }
    }
    
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
    }
    
    


}

