//
//  DataController.swift
//  dogFinder
//
//  Created by Frank Aceves on 9/15/18.
//  Copyright © 2018 Frank Aceves. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    init(modelName: String) {
        container = NSPersistentContainer(name: modelName)
    }
    
    func load() {
        container.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
        }
    }
}
