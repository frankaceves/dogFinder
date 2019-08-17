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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
    }
    
    let reachability = Reachability()!
    
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
            //cell.frame.size.height = dogImage.size.height
            //return cell
            print("dogImage size: \(dogImage.size.width)w, \(dogImage.size.height)h for indexPathRow: \(indexPath.row)")
        } else {
            print("no dog image present")
            cell.favoriteDogImageView.image = #imageLiteral(resourceName: "shiba-8.JPG")
        }
        
        cell.backgroundColor = .green
        print("cell size: \(cell.frame.size.width)w, \(cell.frame.size.height)h for indexPathRow: \(indexPath.row)")
        
        return cell
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
