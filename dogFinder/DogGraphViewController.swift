//
//  DogGraphViewController.swift
//  dogFinder
//
//  Created by Frank Aceves on 9/4/19.
//  Copyright © 2019 Frank Aceves. All rights reserved.
//

import UIKit
import Charts

class DogGraphViewController: UIViewController {
    
    @IBOutlet weak var pieChart: PieChartView!
    
    let breedsArray: [String] = ["Terrier", "Terrier", "Hound", "Hound", "Mastiff"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pieChartUpdate()
    }
    
    //add fetch here somewhere
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pieChartUpdate()
    }
    
    @IBAction func renderCharts() {
        pieChartUpdate()
    }
    
    
    
    func pieChartUpdate() {
        //future home of bar chart code
        let mappedItems = breedsArray.map { ($0, 1) }
        let counts = Dictionary(mappedItems, uniquingKeysWith: +)
        print(counts)
        let keys = counts.keys
        print(keys)
        let dataSet = PieChartDataSet(entries: [], label: nil)
        
        for key in keys {
            let entry = PieChartDataEntry(value: Double(counts[key] ?? 0), label: key)
            dataSet.append(entry)
        }

        let data = PieChartData(dataSet: dataSet)
        pieChart.data = data
        

        //All other additions to this function will go here
        dataSet.colors = ChartColorTemplates.pastel()

        //This must stay at end of function
        pieChart.notifyDataSetChanged()
        pieChart.animate(xAxisDuration: 1.0, easingOption: .easeOutCirc)
    }
}
