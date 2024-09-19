//
//  Persistence.swift
//  resapp
//
//  Created by Cody Hall on 9/18/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<5 {
            let newJob = JobEntity(context: viewContext)
            newJob.jobTitle = "Job \(i + 1)"
            newJob.company = "Company \(i + 1)"
            newJob.startDate = Date().addingTimeInterval(Double(-i) * 86400 * 30)
            newJob.endDate = Date().addingTimeInterval(Double(-i + 1) * 86400 * 30)
            
            let descript = DescriptEntity(context: viewContext)
            descript.text = "Descript for Job \(i + 1)"
            newJob.addToDescript(descript)
            
            let skill = SkillEntity(context: viewContext)
            skill.name = "Skill \(i + 1)"
            newJob.addToSkill(skill)
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "resapp")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescriptions, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
