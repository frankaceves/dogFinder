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
    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    
    var tempDog: [String: String] = [:]
    var currentDog: Dog!
    var breedArray: [String]!
    var imageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        breedLabel.isHidden = true
        activityIndicator.color = UIColor.blue
        randomDogButtonPressed(self)
    }
    
    let reachability = Reachability()!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupFetchedResultsController()
        
        //add reachability observer
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        
        do {
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier: \(error.localizedDescription)")
        }
        
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        
        switch reachability.connection {
        case .wifi:
            reloadButton.isEnabled = true
            favoritesButton.isEnabled = shouldEnable()
            self.view.alpha = 1.0
        case .cellular:
            reloadButton.isEnabled = true
            favoritesButton.isEnabled = shouldEnable()
            self.view.alpha = 1.0
        case .none:
            let ac = UIAlertController(title: "Network Error", message: "Your phone has lost its connection", preferredStyle: .alert)
            ac.addAction(okAction)
            
            reloadButton.isEnabled = false
            favoritesButton.isEnabled = false
            self.view.alpha = 0.25
            
            present(ac, animated: true, completion: nil)
        }
    }
    
    func shouldEnable() -> Bool {
        if tempDog.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    func isFavorite() -> Bool {
        if let fetchedDogs = fetchedResultsController.fetchedObjects {
            for dog in fetchedDogs {
                if let dogPhotoUrl = dog.photoURL {
                    if tempDog.keys.contains(dogPhotoUrl) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    // MARK: - CORE DATA RELATED
    fileprivate func setupFetchedResultsController() {
        
        let fetchRequest: NSFetchRequest<FavoriteDog> = FavoriteDog.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "breed", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - ACTIONS
    @IBAction func showBreedOrSubBreed(_ sender: UISegmentedControl) {
        switch breedSegControl.selectedSegmentIndex {
        case 1: // show SubBreed info, if present
            if currentDog.subBreed != "" {
                breedLabel.text = "Sub-Breed: \(currentDog.subBreed)"
            } else {
                breedLabel.text = "No Sub-Breed Information"
            }
        default: // show breed
            breedLabel.text = "Breed: \(currentDog.breed)"
        }
    }
    
    func configureLoadView(isLoading: Bool) {
        //disable/enable these on load
        reloadButton.isEnabled = !isLoading
        favoritesButton.isEnabled = !isLoading
        breedSegControl.isEnabled = !isLoading
        
        switch isLoading { //configure non-boolean view related objects
        case true:
            tempDog.removeAll()
            favoritesButton.tintColor = nil
            activityIndicator.frame = randomDogImageView.bounds
            randomDogImageView.addSubview(activityIndicator)
            randomDogImageView.alpha = 0.5
            activityIndicator.startAnimating()
            breedSegControl.selectedSegmentIndex = 0
        default: //false - not loading
            randomDogImageView.alpha = 1.0
            breedLabel.isHidden = false
            activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func randomDogButtonPressed(_ sender: Any) {
        configureLoadView(isLoading: true)
        
        DogClient.sharedInstance.showRandomDog { [unowned self] (dog, error) in
            guard error == nil else {
                return
            }
            guard let dog = dog else {
                return
            }
            
            self.currentDog = dog
            
            DispatchQueue.main.async {
                let image = RandomDogImage()
                
                self.randomDogImageView.image = image.getImageFrom(dog.imageData)
                self.configureLoadView(isLoading: false)
                self.breedLabel.text = dog.breed
                // MARK: TODO: CHECK IF DOG IS FAVORITE
            }
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
        dog.imageData = imageData
        
        //save context
        do {
            try dataController.viewContext.save()
            
        } catch {
            fatalError("could not save Dog entity: \(error.localizedDescription)")
        }
    }
    
    func removeDog(dogInfo: [String:String]) {
        let favoriteDogs = fetchedResultsController.fetchedObjects!
        
        for (url, _) in dogInfo {
            let dog = favoriteDogs.filter {
                $0.photoURL == url
            }[0]
            
            dataController.viewContext.delete(dog)

            do {
                try dataController.viewContext.save()
            } catch {
                fatalError("could not delete Dog entity: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func favoritesButtonPressed(_ sender: Any) {
        if isFavorite() == true {
            removeDog(dogInfo: tempDog)
            favoritesButton.tintColor = nil
            try? fetchedResultsController.performFetch()
        } else {
            addDog(dogInfo: tempDog)
            favoritesButton.tintColor = UIColor.red
            try? fetchedResultsController.performFetch()
        }
    }
}

