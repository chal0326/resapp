//
//  JobEntity+CoreDataProperties.swift
//  resapp
//
//  Created by Cody Hall on 9/20/24.
//
//

import Foundation
import CoreData


extension JobEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<JobEntity> {
        return NSFetchRequest<JobEntity>(entityName: "JobEntity")
    }

    @NSManaged public var company: String?
    @NSManaged public var endDate: Date?
    @NSManaged public var jobTitle: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var descript: NSSet?
    @NSManaged public var skill: NSSet?

}

// MARK: Generated accessors for descript
extension JobEntity {

    @objc(addDescriptObject:)
    @NSManaged public func addToDescript(_ value: DescriptEntity)

    @objc(removeDescriptObject:)
    @NSManaged public func removeFromDescript(_ value: DescriptEntity)

    @objc(addDescript:)
    @NSManaged public func addToDescript(_ values: NSSet)

    @objc(removeDescript:)
    @NSManaged public func removeFromDescript(_ values: NSSet)

}

// MARK: Generated accessors for skill
extension JobEntity {

    @objc(addSkillObject:)
    @NSManaged public func addToSkill(_ value: SkillEntity)

    @objc(removeSkillObject:)
    @NSManaged public func removeFromSkill(_ value: SkillEntity)

    @objc(addSkill:)
    @NSManaged public func addToSkill(_ values: NSSet)

    @objc(removeSkill:)
    @NSManaged public func removeFromSkill(_ values: NSSet)

}

extension JobEntity : Identifiable {

}
