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
    var tempDog: String = ""
    var breedArray: [String]!
    var imageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
        
        if isFavorite() {
            favoritesButton.tintColor = UIColor.red
        } else {
            favoritesButton.tintColor = nil
        }
        
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
        //if tempDog is empty, disable buttons
        if tempDog.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    func isFavorite() -> Bool {
        if let fetchedDogs = fetchedResultsController.fetchedObjects {
            for dog in fetchedDogs {
                if tempDog == dog.photoURL {
                    return true
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
    
    @IBAction func randomDogButtonPressed(_ sender: Any) {
        favoritesButton.isEnabled = false
        reloadButton.isEnabled = false
        tempDog.removeAll()
        favoritesButton.tintColor = nil
        
        activityIndicator.color = UIColor.blue
        activityIndicator.frame = randomDogImageView.bounds
        randomDogImageView.addSubview(activityIndicator)
        randomDogImageView.alpha = 0.5
        activityIndicator.startAnimating()
        
        
        DogClient.sharedInstance.showRandomDog { (image, imageData, urlString, error) in
            
            guard error == nil else {
                print("there was an error: \(error!)")
                return
            }
            
            guard let urlString = urlString else {
                print("no dogURL string returned from showRandomDog")
                return
            }
            
            guard let imageData = imageData else {
                print("no image data returned from showRandomDog")
                return
            }
            
            self.imageData = imageData
            
            guard let image = image else {
                print("no photo returned")
                
                //display dog placeholder if no image present
                DispatchQueue.main.async {
                    self.randomDogImageView.image = #imageLiteral(resourceName: "shiba-8.JPG")
                    self.activityIndicator.stopAnimating()
                }
                
                return
            }
            
            //if image is present, update UI with image, and check if it's a favorite.
            DispatchQueue.main.async {
                self.randomDogImageView.image = image
                self.randomDogImageView.alpha = 1.0
                
                //print("urlString = \(urlString)")
                
                
                if self.isFavorite() == true {
                    self.favoritesButton.isEnabled = true
                    self.favoritesButton.tintColor = UIColor.red
                } else {
                    self.favoritesButton.isEnabled = true
                    self.favoritesButton.tintColor = nil
                }
                
                self.reloadButton.isEnabled = true
                self.activityIndicator.stopAnimating()
            }
            
            //self.tempDog.updateValue(self.breedArray[0], forKey: urlString)
            self.tempDog.append(urlString)
            
        }
    }
    
    func addDog(dogUrl: String) {
        
        //create FavoriteDog entity
        let dog = FavoriteDog(context: dataController.viewContext)
        
        //assign attributes
        dog.photoURL = dogUrl
        dog.breed = nil
        dog.imageData = imageData
        
        //save context
        do {
            try dataController.viewContext.save()
            
        } catch {
            print("could not save Dog entity: \(error.localizedDescription)")
        }
    }
    
    func removeDog(dogUrl: String) {
        let favoriteDogs = fetchedResultsController.fetchedObjects!
        
            for dog in favoriteDogs {
                if dogUrl == dog.photoURL {
                    dataController.viewContext.delete(dog)
                }
            }
            //save context
            do {
                try dataController.viewContext.save()
                
            } catch {
                fatalError("could not delete Dog entity: \(error.localizedDescription)")
            }
        
    }
    
    @IBAction func favoritesButtonPressed(_ sender: Any) {
        //if tempDog is already a favorite
        if isFavorite() == true {
            //delete dog from coreData
            //toggle tint nil
            removeDog(dogUrl: tempDog)
            favoritesButton.tintColor = nil
            try? fetchedResultsController.performFetch()
        } else { //tempDog is not already a favorite
            //add dog to coreData
            //toggle tint red
            addDog(dogUrl: tempDog)
            favoritesButton.tintColor = UIColor.red
            try? fetchedResultsController.performFetch()
        }
    }
}

