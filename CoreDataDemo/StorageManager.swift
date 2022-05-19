//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by VG on 18.05.2022.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let viewContext: NSManagedObjectContext

    private init () {
        viewContext = persistentContainer.viewContext
    }
    
    // MARK: - Public Methods
    func fetchData(completion: (Result<[Task], Error>) -> Void) {
        let fetchRequest = Task.fetchRequest()
        do {
            let tasks = try viewContext.fetch(fetchRequest)
            completion(.success(tasks))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func save(_ taskName: String, completion: (Task) -> Void) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: viewContext) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: viewContext) as? Task else { return }
        
        task.title = taskName
        completion(task)
        saveContext()
    }
    
    func edit(_ task: Task, newName: String) {
        task.title = newName
        saveContext()
    }
    
    func delete(_ task: Task) {
        viewContext.delete(task)
        saveContext()
    }

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
