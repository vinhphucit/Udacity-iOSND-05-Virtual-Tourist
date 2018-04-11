//
//  CoreDataStackManager.swift
//  Virtual Tourist
//
//  Created by Phuc Tran on 4/10/18.
//  Copyright © 2018 Phuc Tran. All rights reserved.
//


import Foundation
import CoreData

class DataController {
    
    let persistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    let backgroundContext:NSManagedObjectContext!
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
//            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
    
    static let shared = DataController(modelName: "VirtualTourist")
}

// MARK: - Autosaving

extension DataController {

        func saveContext() {
            if self.viewContext.hasChanges {
                do {
                    try self.viewContext.save()
                } catch {
                    print("Error occured while saving persistent store: \(error), \(error._userInfo)")
                    
                }
            }
        }

}

extension DataController {
    func fetchPin(_ predicate: NSPredicate, sorting: NSSortDescriptor? = nil) throws -> Pin? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let pin = (try viewContext.fetch(fr) as! [Pin]).first else {
            return nil
        }
        return pin
    }
    
    func fetchAllPins() throws -> [Pin]? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")

        guard let pin = try viewContext.fetch(fr) as? [Pin] else {
            return nil
        }
        return pin
    }
    
    func fetchPhotos(_ predicate: NSPredicate? = nil, sorting: NSSortDescriptor? = nil) throws -> [Photo]? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let photos = try viewContext.fetch(fr) as? [Photo] else {
            return nil
        }
        return photos
    }
}

