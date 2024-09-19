import Foundation
import CoreData

extension JobEntity: Identifiable {
    var descriptionsArray: [DescriptionEntity] {
        let set = descriptions as? Set<DescriptionEntity> ?? []
        return set.sorted {
            $0.text ?? "" < $1.text ?? ""
        }
    }

    var skillsArray: [SkillEntity] {
        let set = skills as? Set<SkillEntity> ?? []
        return set.sorted {
            $0.name ?? "" < $1.name ?? ""
        }
    }

    var isValid: Bool {
        guard jobTitle.count >= 3, company.count >= 2 else {
            return false
        }
        
        guard startDate <= endDate else {
            return false
        }
        
        guard let descriptions = descriptions, !descriptions.isEmpty else {
            return false
        }
        
        guard let skills = skills, !skills.isEmpty else {
            return false
        }
        
        return true
    }
}