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
    @IBOutlet weak var breedSegControl: UISegmentedControl!
    
    var fetchedResultsController: NSFetchedResultsController<FavoriteDog>!
    
    var dataController: DataController!
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var favoriteDogs = [[String: String]]()
    var tempDog: [String: String] = [:]
    var breedArray: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("viewDidLoad")
        breedLabel.isHidden = true
        breedSegControl.isHidden = true
        favoritesButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("viewWillAppear RandomDogVC")
        setupFetchedResultsController()
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
    
    // MARK: - CORE DATA RELATED
    fileprivate func setupFetchedResultsController() {
        print("func setupFetchedResultsController")
        let fetchRequest: NSFetchRequest<FavoriteDog> = FavoriteDog.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "breed", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            print("success fetching?")
            print("fetchedObjects: \(String(describing: fetchedResultsController.fetchedObjects?.count))")
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - ACTIONS
    @IBAction func showBreedOrSubBreed(_ sender: UISegmentedControl) {
        switch breedSegControl.selectedSegmentIndex {
        case 1:
            if breedArray.count > 1 {
                breedLabel.text = "Sub-Breed: \(breedArray[1])"
            } else {
                breedLabel.text = "No Sub-Breed Found"
            }
        default:
            if breedLabel.text != breedArray[0] {
                breedLabel.text = "Breed: \(breedArray[0])"
            }
        }
    }
    
    @IBAction func randomDogButtonPressed(_ sender: Any) {
        tempDog.removeAll()
        favoritesButton.tintColor = nil
        breedSegControl.isEnabled = false
        activityIndicator.color = UIColor.blue
        activityIndicator.frame = randomDogImageView.bounds
        randomDogImageView.addSubview(activityIndicator)
        randomDogImageView.alpha = 0.5
        activityIndicator.startAnimating()
        breedSegControl.selectedSegmentIndex = 0
        
        DogClient.sharedInstance.showRandomDog { (image, urlString, error) in
            
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
            
            self.breedArray = DogClient.sharedInstance.getBreedAndSubBreed(urlString: urlString)
            
            DispatchQueue.main.async {
                self.breedSegControl.isHidden = false
                self.breedSegControl.isEnabled = true
                self.randomDogImageView.image = image
                self.randomDogImageView.alpha = 1.0
                self.breedLabel.text = "Breed: \(self.breedArray[0])"
                self.breedLabel.isHidden = false
                self.favoritesButton.isEnabled = true
                self.activityIndicator.stopAnimating()
            }
            
            self.tempDog.updateValue(self.breedArray[0], forKey: urlString)
            print("tempDog info: \(self.tempDog)")
            
        }
    }
    
    func addDog(dogInfo: [String:String]) {
        //get components of dogInfo = [urlString: Breed]
        var url: String!
        var breed: String!
        
        for (x, y) in dogInfo {
            url = x
            breed = y
        }
        
        //create FavoriteDog entity
        let dog = FavoriteDog(context: dataController.viewContext)
        
        //assign attributes
        dog.photoURL = url
        dog.breed = breed
        
        //save context
        do {
            try dataController.viewContext.save()
            print("dog saved?")
        } catch {
            fatalError("could not save Dog entity: \(error.localizedDescription)")
        }
    }
    
    @IBAction func favoritesButtonPressed(_ sender: Any) {
        //toggle tint
        //add tempDog to favoritesArray
        //clear tempDog
        if favoritesButton.tintColor == nil {
            favoritesButton.tintColor = UIColor.red
            addDog(dogInfo: tempDog)
            FavoriteDogsTEMP.sharedInstance.favoriteDogs.append(tempDog)
            
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
}

