//
//  CoreDataHelper.swift
//  Thoughtless
//
//  Created by Yohannes Wijaya on 1/14/17.
//  Copyright © 2017 Yohannes Wijaya. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelper: NSObject {
    
    class func insertManagedObject(_ className: String, managedObjectContext: NSManagedObjectContext) -> AnyObject {
        return NSEntityDescription.insertNewObject(forEntityName: className, into: managedObjectContext)
    }
    
    class func fetchEntities(_ className: String, managedObjectContext: NSManagedObjectContext, predicate: NSPredicate?) -> Array<Any> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entityDescription = NSEntityDescription.entity(forEntityName: className, in: managedObjectContext)
        fetchRequest.entity = entityDescription
        if predicate != nil { fetchRequest.predicate = predicate }
        fetchRequest.returnsObjectsAsFaults = false
        
        let items = try? managedObjectContext.execute(fetchRequest)
        return items
    }
}
