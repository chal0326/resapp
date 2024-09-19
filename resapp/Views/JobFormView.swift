import SwiftUI
import CoreData

struct JobFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var jobTitle: String = ""
    @State private var company: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var descriptions: [String] = [""]
    @State private var skills: [String] = [""]
    @State private var showAlert = false
    @State private var alertMessage = ""

    var job: JobEntity?

    init(job: JobEntity? = nil) {
        self.job = job
        _jobTitle = State(initialValue: job?.jobTitle ?? "")
        _company = State(initialValue: job?.company ?? "")
        _startDate = State(initialValue: job?.startDate ?? Date())
        _endDate = State(initialValue: job?.endDate ?? Date())
        
        // Ensure proper type annotations for descriptions and skill
        
        // Ensure proper type annotations for descriptions and skill
        _descriptions = State(initialValue: job?.descriptArray.map { $0.text ?? "" }.map { $0.text ?? "" } ?? [""]) // Assuming descriptionsArray is an array of DescriptionEntity // Assuming descriptionsArray is an array of DescriptionEntity
        _skills = State(initialValue: job?.skillArray.map { $0.name ?? "" }.map { $0.name ?? "" } ?? [""]) // Assuming skillArray is an array of SkillEntity // Assuming skillArray is an array of SkillEntity
    }

    var body: some View {
        Form {
            // ... (keep the existing form sections)
        }
        .navigationTitle(job == nil ? "Add Job" : "Edit Job")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if job == nil {
                        // Save action
                        if isValidInput() {
                            saveJob()
                        }
                    } else {
                        // Update action
                        if isValidInput() {
                            saveJob()
                        }
                    }
                }) {
                    Text(job == nil ? "Save" : "Update") // Set button title based on job state
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func saveJob() {
        withAnimation {
            let jobToSave = job ?? JobEntity(context: viewContext)
            jobToSave.jobTitle = jobTitle
            jobToSave.company = company
            jobToSave.startDate = startDate
            jobToSave.endDate = endDate

            // Remove existing descript and skill
            jobToSave.descript?.forEach { viewContext.delete($0 as! NSManagedObject) }
            jobToSave.skill?.forEach { viewContext.delete($0 as! NSManagedObject) }

            // Add new descript and skill
            for desc in descriptions where !desc.isEmpty {
                let descriptions = DescriptEntity(context: viewContext)
                descriptions.text = desc
                jobToSave.addToDescript(descriptions)
            }

            for skl in skills where !skl.isEmpty {
                let skills = SkillEntity(context: viewContext)
                skills.name = skl
                jobToSave.addToSkill(skills)
            }

            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func isValidInput() -> Bool {
        // Check if job title and company are not empty and have a minimum length
        guard jobTitle.count >= 3, company.count >= 2 else {
            alertMessage = "Job title must be at least 3 characters and company name at least 2 characters long." // Set the alert message
            showAlert = true // Set showAlert to true to trigger the alert
            return false
        }

        // Check if start date is before end date
        guard startDate <= endDate else {
            alertMessage = "Start date must be before or equal to the end date." // Set the alert message
            showAlert = true // Set showAlert to true to trigger the alert
            return false
        }
        
        // Check if at least one description is provided
        guard descriptions.contains(where: { !$0.isEmpty }) else {
            alertMessage = "Please add at least one job description." // Set the alert message
            showAlert = true // Set showAlert to true to trigger the alert
            return false
        }
        
        // Check if at least one skill is provided
        guard skills.contains(where: { !$0.isEmpty }) else {
            alertMessage = "Please add at least one skill." // Set the alert message
            showAlert = true // Set showAlert to true to trigger the alert
            return false
        }
        
        return true
    }

    // ... (keep the existing showAlert method)
}
