import Foundation
import CoreData

extension JobEntity: Identifiable {
    var descriptArray: [DescriptEntity] {
        let set = descript as? Set<DescriptEntity> ?? []
        return set.sorted {
            $0.text ?? "" < $1.text ?? ""
        }
    }

    var skillArray: [SkillEntity] {
        let set = skill as? Set<SkillEntity> ?? []
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
        
        guard let descript = descript, !descript.isEmpty else {
            return false
        }
        
        guard let skill = skill, !skill.isEmpty else {
            return false
        }
        
        return true
    }
}