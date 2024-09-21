//
//  SkillEntity+CoreDataProperties.swift
//  resapp
//
//  Created by Cody Hall on 9/20/24.
//
//

import Foundation
import CoreData


extension SkillEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SkillEntity> {
        return NSFetchRequest<SkillEntity>(entityName: "SkillEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var job: JobEntity?

}

extension SkillEntity : Identifiable {

}
