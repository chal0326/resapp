//
//  JobEntity+CoreDataProperties.swift
//  resapp
//
//  Created by Cody Hall on 9/19/24.
//
//

import Foundation
import CoreData


extension JobEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<JobEntity> {
        return NSFetchRequest<JobEntity>(entityName: "JobEntity")
    }

    @NSManaged public var jobTitle: String?
    @NSManaged public var company: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var descriptions: DescriptionEntity?
    @NSManaged public var skills: SkillEntity?

}

extension JobEntity : Identifiable {

}
