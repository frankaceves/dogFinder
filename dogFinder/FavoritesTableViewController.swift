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
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    let reachability = Reachability()!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View will appear: FavoritesTableVC")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via Wifi")
            self.view.alpha = 1.0
        case .cellular:
            print("Reachable via Cellular")
            self.view.alpha = 1.0
        case .none:
            print("Network not reachable")
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
            print("success fetching favorites in FavTableVC?")
            print("fetchedObjects FTVC: \(String(describing: fetchedResultsController.fetchedObjects?.count))")
        } catch {
            fatalError("error fetching favorites in FavTableVC: \(error.localizedDescription)")
        }
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dogCell", for: indexPath) as! FavoriteDogTableViewCell
        
        
        cell.favoriteDogImageView.image = nil
        
        cell.favoriteDogImageView.alpha = 1.0
        
        
        activityIndicator.frame = cell.favoriteDogImageView.bounds
        activityIndicator.backgroundColor = UIColor.blue
        //activityIndicator.color = UIColor.darkGray
        
        cell.favoriteDogImageView.addSubview(activityIndicator)
        
        
        
        
        let dog = fetchedResultsController.fetchedObjects![indexPath.row]
        
        // Configure cell from CoreData
        cell.favoriteDogBreedLabel.text = "Breed: \(dog.breed ?? "No Breed Info Available")"
        
        
        if dog.imageData != nil {
            activityIndicator.stopAnimating()
            
            let dogImage = UIImage(data: dog.imageData!)
            cell.favoriteDogImageView.image = dogImage
            return cell
        } else {
            print("no dog image present")
            cell.favoriteDogImageView.image = #imageLiteral(resourceName: "shiba-8.JPG")
        }
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
 

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
