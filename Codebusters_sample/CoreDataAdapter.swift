//
//  CoreDataAdapter.swift
//  Kids'n'Code
//
//  Created by Alexander on 03/11/15.
//  Copyright © 2015 Kids'n'Code. All rights reserved.
//

import Foundation
import CoreData

class CoreDataAdapter: NSObject {
    
    class var sharedAdapter: CoreDataAdapter {
        struct Singleton {
            static let sharedAdapter = CoreDataAdapter()
        }
        
        return Singleton.sharedAdapter
    }
    
    let coordinator: NSPersistentStoreCoordinator
    let model: NSManagedObjectModel
    let context: NSManagedObjectContext
    
    private override init() {
        let modelURL = NSBundle.mainBundle()
            .URLForResource("CBDataModel",
                withExtension: "momd")!
        model = NSManagedObjectModel(
            contentsOfURL: modelURL)!
        
        let fileManager = NSFileManager.defaultManager()
        let docsURL: AnyObject? = fileManager.URLsForDirectory(
            .DocumentDirectory, inDomains: .UserDomainMask).last
        let storeURL = docsURL!
            .URLByAppendingPathComponent("CBDataModel.sqlite")
        
        coordinator = NSPersistentStoreCoordinator(
            managedObjectModel: model)
        let failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        
        context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        super.init()
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
        
    }
    
    
    
    //  AddNewLevel
    //
    
    func addNewLevel(levelNumber : Int , levelPackNumber : Int, finished : Bool , time : Double , actions : [String!] , touchedNodes : [String!]) {
        
        let newLevel = NSEntityDescription.insertNewObjectForEntityForName("Level", inManagedObjectContext: context) as! Level
        (newLevel.levelNumber , newLevel.levelPackNumber , newLevel.time , newLevel.finished, newLevel.date) = (levelNumber , levelPackNumber , time , finished , NSDate())
        
        for action in actions {
            let newAction = NSEntityDescription.insertNewObjectForEntityForName("Action", inManagedObjectContext: context) as! Action
            newAction.actionType = action
            newAction.level = newLevel
        }
        
        for touchedNode in touchedNodes {
            let newtouch = NSEntityDescription.insertNewObjectForEntityForName("Touch", inManagedObjectContext: context) as! Touch
            newtouch.touchedNode = touchedNode
            newtouch.level = newLevel
        }
        print("Adding level number \(levelNumber) from pack number \(levelPackNumber)")
        save()
    }
    
    
    //  Fetch requests
    //  Get all levels
    
    func getLevels() throws -> [Level!] {
        let request = NSFetchRequest(entityName: "Level")
        request.fetchLimit = 100
        let result = try context.executeFetchRequest(request) as! [Level!]
        return result
    }
    // delete levels
    
    func deleteAllLevels() throws {
        let request = NSFetchRequest(entityName: "Level")
        let fetchResults = try context.executeFetchRequest(request) as! [NSManagedObject!]
        
        
        if let managedObjects = fetchResults as? [NSManagedObject] {
            for object in managedObjects {
                context.deleteObject(object)
            }
        }
        print("Deleting CoreData")
        save()
}
}
