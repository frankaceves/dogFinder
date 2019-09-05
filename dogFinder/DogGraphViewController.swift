//
//  DogGraphViewController.swift
//  dogFinder
//
//  Created by Frank Aceves on 9/4/19.
//  Copyright © 2019 Frank Aceves. All rights reserved.
//

import UIKit
import Charts
import CoreData

class DogGraphViewController: UIViewController {
    var fetchedResultsController: NSFetchedResultsController<FavoriteDog>!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var dataController: DataController!
    
    
    @IBOutlet weak var pieChart: PieChartView!
    
    var breedsArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //pieChartUpdate()
        dataController = appDelegate.dataController
        
        if fetchedResultsController == nil {
            //print("fetch results controller is nil")
            setupFetchedResultsController()
        }
        
    }
    
    //add fetch here somewhere
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForUpdates()
        
        if fetchedResultsController != nil {
            pieChartUpdate()
        }
        
        
    }
    
    func checkForUpdates() {
        if dataController != nil {
                do {
                    try fetchedResultsController.performFetch()
                } catch {
                    fatalError("error checking for update fetch: \(error.localizedDescription)")
                }
        }
    }
    
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
    
    
    
    func pieChartUpdate() {
        let dataSet = PieChartDataSet(entries: [], label: nil)
        
        
        guard let fetchedObjects = fetchedResultsController.fetchedObjects, !fetchedObjects.isEmpty else {
            print("no fetched objects")
            let data = PieChartData(dataSet: dataSet)
            pieChart.data = data
            pieChart.notifyDataSetChanged()
            pieChart.centerText = "No Dogs to Display"
            return
        }
        
        //print("fetchedObjects: \(fetchedObjects)")
        breedsArray = fetchedObjects.map { $0.breed! }
        //print("breedsArray: \(breedsArray)")
        
        //future home of bar chart code
        let mappedItems = breedsArray.map { ($0, 1) }
        let counts = Dictionary(mappedItems, uniquingKeysWith: +)
        //print(counts)
        let keys = counts.keys.sorted()
        //print(keys)
        
        
        for key in keys {
            let entry = PieChartDataEntry(value: Double(counts[key] ?? 0), label: key)
            dataSet.append(entry)
        }

        let data = PieChartData(dataSet: dataSet)
        pieChart.data = data
        

        //All other style additions to this function will go here
        dataSet.colors = ChartColorTemplates.pastel()
        pieChart.centerText = "Your Favorite Dogs"

        //This must stay at end of function
        pieChart.notifyDataSetChanged()
        pieChart.animate(xAxisDuration: 1.0, easingOption: .easeOutCirc)
    }
}
