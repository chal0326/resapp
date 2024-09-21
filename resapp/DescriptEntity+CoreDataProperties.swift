//
//  DescriptEntity+CoreDataProperties.swift
//  resapp
//
//  Created by Cody Hall on 9/20/24.
//
//

import Foundation
import CoreData


extension DescriptEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DescriptEntity> {
        return NSFetchRequest<DescriptEntity>(entityName: "DescriptEntity")
    }

    @NSManaged public var text: String?
    @NSManaged public var job: JobEntity?

}

extension DescriptEntity : Identifiable {

}
