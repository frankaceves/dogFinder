//
//  ViewController.swift
//  puppyFinder
//
//  Created by Frank Aceves on 9/3/18.
//  Copyright © 2018 Frank Aceves. All rights reserved.
//

import UIKit
import CoreData
import Reachability

enum LoadState {
    case loading, notLoading, error
}

class RandomDogViewController: UIViewController {
    
    @IBOutlet var randomDogImageView: UIImageView!
    @IBOutlet var reloadButton: UIBarButtonItem!
    @IBOutlet var breedLabel: UILabel!
    @IBOutlet weak var favoritesButton: UIBarButtonItem!
    @IBOutlet weak var breedSegControl: UISegmentedControl!
    
    var fetchedResultsController: NSFetchedResultsController<FavoriteDog>!
    
    var dataController: DataController!
    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    
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
        
        // update favoritesButton based on isFavorite status
        if let currentDog = currentDog {
            if !isFavorite(dog: currentDog) {
                favoritesButton.tintColor = nil
            }
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        let ac = UIAlertController(title: "Network Error", message: "Your phone has lost its connection", preferredStyle: .alert)
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
            ac.addAction(okAction)
            
            reloadButton.isEnabled = false
            favoritesButton.isEnabled = false
            self.view.alpha = 0.25
            
            //present(ac, animated: true, completion: nil)
        }
    }
    
    func shouldEnable() -> Bool {
        if currentDog == nil {
            return false
        } else { //currentDog != nil
            return true
        }
    }
    
    func isFavorite(dog: Dog) -> Bool {
        if let fetchedDogs = fetchedResultsController.fetchedObjects {
            return fetchedDogs.contains { fetchedDog in
                fetchedDog.photoURL == dog.urlString
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
    
    func configureLoadView(state: LoadState) {
        //disable/enable these on load
//        reloadButton.isEnabled = !isLoading
//        favoritesButton.isEnabled = !isLoading
//        breedSegControl.isEnabled = !isLoading
        
        switch state { //configure non-boolean view related objects
        case .loading:
            print("STATE: loading")
            reloadButton.isEnabled = false
            favoritesButton.isEnabled = false
            breedSegControl.isEnabled = false
            
            favoritesButton.tintColor = nil
            
            let mainWrapperView = randomDogImageView.superview!
            activityIndicator.frame = mainWrapperView.bounds
            activityIndicator.center = CGPoint(x: mainWrapperView.frame.width / 2, y: mainWrapperView.frame.height / 2)
            mainWrapperView.addSubview(activityIndicator)

            randomDogImageView.alpha = 0.5
            activityIndicator.startAnimating()
            breedSegControl.selectedSegmentIndex = 0
            
        case .notLoading: //false - not loading
            print("STATE: NOT loading")
            randomDogImageView.alpha = 1.0
            breedLabel.isHidden = false
            activityIndicator.stopAnimating()
            reloadButton.isEnabled = true
            favoritesButton.isEnabled = true
            breedSegControl.isEnabled = true
            
        case .error:
            print("STATE: ERROR")
            activityIndicator.stopAnimating()
            reloadButton.isEnabled = true
            favoritesButton.isEnabled = false
            breedSegControl.isEnabled = false
            let ac = UIAlertController(title: "Error", message: "There was an error.  Please click the refresh button", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .default)
            ac.addAction(okButton)
            present(ac, animated: true)
        }
    }
    
    @IBAction func randomDogButtonPressed(_ sender: Any) {
        currentDog = nil
        configureLoadView(state: .loading)
        
        DogClient.sharedInstance.showRandomDog { [unowned self] (dog, error) in
            guard error == nil else {
                print("error in ShowRandomDog: \(error!)")
                print("current Reachability: \(self.reachability.connection)")
                DispatchQueue.main.async {
                    self.configureLoadView(state: .error)
                }
                return
            }

            // rewrite this to prevent a throwing guard func
            guard let dog = dog else {
                print("no random dog to show")
                
                return
            }
            
            self.currentDog = dog
            
            
            DispatchQueue.main.async {
                let image = RandomDogImage().getImageFrom(dog.imageData)
                
                //self.randomDogImageView.image = image.getImageFrom(dog.imageData)
                self.randomDogImageView.image = image
                self.configureLoadView(state: .notLoading)
                self.breedLabel.text = dog.breed
                // MARK: TODO: CHECK IF DOG IS FAVORITE
                if self.isFavorite(dog: dog) {
                    self.favoritesButton.tintColor = .red
                }
            }
        }
    }
    
    func addDog(dogInfo: Dog) {
        
        //create FavoriteDog entity
        let dog = FavoriteDog(context: dataController.viewContext)
        
        //assign attributes
        dog.photoURL = dogInfo.urlString
        dog.breed = dogInfo.breed
        dog.subBreed = dogInfo.subBreed
        dog.imageData = dogInfo.imageData
        
        //save context
        do {
            try dataController.viewContext.save()
            
        } catch {
            fatalError("could not save Dog entity: \(error.localizedDescription)")
        }
    }
    
    func removeDog(dogInfo: Dog) {
        let favoriteDogs = fetchedResultsController.fetchedObjects!
        
        let matchingDog = favoriteDogs.filter {
            $0.photoURL == dogInfo.urlString
        }[0]
        
        dataController.viewContext.delete(matchingDog)
        
        do {
            try dataController.viewContext.save()
        } catch {
            fatalError("could not delete Dog entity: \(error.localizedDescription)")
        }
    }
    
    @IBAction func favoritesButtonPressed(_ sender: Any) {
        if isFavorite(dog: currentDog) == true {
            removeDog(dogInfo: currentDog)
            favoritesButton.tintColor = nil
            try? fetchedResultsController.performFetch()
        } else {
            addDog(dogInfo: currentDog)
            favoritesButton.tintColor = UIColor.red
            try? fetchedResultsController.performFetch()
        }
    }
}

