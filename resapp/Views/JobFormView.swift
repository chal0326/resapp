import SwiftUI
import CoreData

struct JobFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var jobTitle: String = ""
    @State private var company: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var descript: [String] = [""]
    @State private var skill: [String] = [""]
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var job: JobEntity?

    init(job: JobEntity? = nil) {
        self.job = job
        _jobTitle = State(initialValue: job?.jobTitle ?? "")
        _company = State(initialValue: job?.company ?? "")
        _startDate = State(initialValue: job?.startDate ?? Date())
        _endDate = State(initialValue: job?.endDate ?? Date())
        _descript = State(initialValue: job?.descriptArray ?? [""])
        _skill = State(initialValue: job?.skillArray ?? [""])
    }

    var body: some View {
        Form {
            // ... (keep the existing form sections)
        }
        .navigationTitle(job == nil ? "Add Job" : "Edit Job")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(job == nil ? "Save" : "Update") {
                    if isValidInput() {
                        saveJob()
                    } else {
                        showAlert(message: "Please fill in all required fields and ensure the start date is before the end date.")
                    }
                }
            }
        }
        .alert(isPresented: $showingAlert) {
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
            for desc in descript where !desc.isEmpty {
                let descript = descriptEntity(context: viewContext)
                descript.text = desc
                jobToSave.addToDescript(descript)
            }

            for skl in skill where !skl.isEmpty {
                let skill = SkillEntity(context: viewContext)
                skill.name = skl
                jobToSave.addToSkill(skill)
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
            showAlert(message: "Job title must be at least 3 characters and company name at least 2 characters long.")
            return false
        }
        
        // Check if start date is before end date
        guard startDate <= endDate else {
            showAlert(message: "Start date must be before or equal to the end date.")
            return false
        }
        
        // Check if at least one descript is provided
        guard descript.contains(where: { !$0.isEmpty }) else {
            showAlert(message: "Please add at least one job descript.")
            return false
        }
        
        // Check if at least one skill is provided
        guard skill.contains(where: { !$0.isEmpty }) else {
            showAlert(message: "Please add at least one skill.")
            return false
        }
        
        return true
    }

    // ... (keep the existing showAlert method)
}
