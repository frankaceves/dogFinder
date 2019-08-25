//
//  FavoritesTableViewController.swift
//  dogFinder
//
//  Created by Frank Anthony Aceves on 9/15/18.
//  Copyright © 2018 Frank Aceves. All rights reserved.
//

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController {
    var fetchedResultsController: NSFetchedResultsController<FavoriteDog>!
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterByBreed))
    }
    
    let reachability = Reachability()!
    var commitPredicate: NSPredicate?
    
    @objc func filterByBreed() {
        print("filter tapped")
        var breeds: [String] = []
        //var uniqueBreeds: [String] = []
        var ac = UIAlertController()
        if let fetchedObjects = fetchedResultsController.fetchedObjects, !fetchedObjects.isEmpty {
            breeds = Array(Set(fetchedObjects.compactMap { $0.breed })).sorted()
            
            ac = UIAlertController(title: "Filter By Breed", message: "Choose which breed you only want to see", preferredStyle: .actionSheet)
            
            for breed in breeds {
                ac.addAction(UIAlertAction(title: breed, style: .default, handler: { [unowned self] _ in
                    //self.commitPredicate = NSPredicate(format: <#T##String#>, argumentArray: <#T##[Any]?#>)
                }))
            }
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        } else {
            ac = UIAlertController(title: "No Breeds To Filter", message: "Start favoriting dogs in the search tab, then you can filter", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        }
        
        
        
        
        
        present(ac, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        tableView.reloadData()
        
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
            self.view.alpha = 1.0
        case .cellular:
            self.view.alpha = 1.0
        case .none:
            let ac = UIAlertController(title: "Network Error", message: "Your phone has lost its connection", preferredStyle: .alert)
            ac.addAction(okAction)
            
            self.view.alpha = 0.25
            
            present(ac, animated: true, completion: nil)
        }
    }
    
    // MARK: - CORE DATA
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<FavoriteDog> = FavoriteDog.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "breed", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.fetchRequest.predicate = commitPredicate
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("error fetching favorites in FavTableVC: \(error.localizedDescription)")
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dogCell", for: indexPath) as! FavoriteDogTableViewCell
        
        //cell.favoriteDogImageView.image = nil
        
        let dog = fetchedResultsController.fetchedObjects![indexPath.row]
        
        // Configure cell from CoreData
        cell.favoriteDogBreedLabel.text = "Breed: \(dog.breed ?? "No Breed Info Available")"
        
        if let dogData = dog.imageData, let dogImage = UIImage(data: dogData) {
            cell.favoriteDogImageView.image = dogImage
        } else {
            print("no dog image present")
            cell.favoriteDogImageView.image = #imageLiteral(resourceName: "shiba-8.JPG")
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //print("HEIGHT")
        let dog = fetchedResultsController.fetchedObjects![indexPath.row]
        guard let dogData = dog.imageData, let dogImage = UIImage(data: dogData) else {
            print("error getting dog data, returning 44")
            return 44
        }
        //print("dog image dimensions: \(dogImage.size)")
        let imageRatio = CGFloat(dogImage.size.width / dogImage.size.height)
        
        //print("returning height of \(tableView.frame.width / imageRatio)")
        return tableView.frame.width / imageRatio
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete object from CoreData
            let dog = fetchedResultsController.object(at: indexPath)
            dataController.viewContext.delete(dog)
            
            //save context
            do {
                try dataController.viewContext.save()
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("could not delete Dog entity: \(error.localizedDescription)")
            }
            
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
