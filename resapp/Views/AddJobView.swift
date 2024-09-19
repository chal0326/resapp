import SwiftUI
import CoreData

struct AddJobView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var jobTitle: String = ""
    @State private var company: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()

    @State private var descriptions: [String] = [""]
    @State private var skills: [String] = [""]

    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Form {
            Section(header: Text("Job Details")) {
                TextField("Job Title", text: $jobTitle)
                    .textInputAutocapitalization(.words)
                TextField("Company", text: $company)
                    .textInputAutocapitalization(.words)
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
            }

            Section(header: Text("Descriptions")) {
                ForEach(descriptions.indices, id: \.self) { index in
                    HStack {
                        TextField("Description", text: $descriptions[index])
                        if descriptions.count > 1 {
                            Button(action: {
                                descriptions.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                Button(action: {
                    descriptions.append("")
                }) {
                    Label("Add Description", systemImage: "plus")
                }
            }

            Section(header: Text("Skills")) {
                ForEach(skills.indices, id: \.self) { index in
                    HStack {
                        TextField("Skill", text: $skills[index])
                        if skills.count > 1 {
                            Button(action: {
                                skills.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                Button(action: {
                    skills.append("")
                }) {
                    Label("Add Skill", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Add Job")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    if isValidInput() {
                        addJob()
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

    private func addJob() {
        withAnimation {
            let newJob = JobEntity(context: viewContext)
            newJob.jobTitle = jobTitle
            newJob.company = company
            newJob.startDate = startDate
            newJob.endDate = endDate

            for desc in descriptions where !desc.isEmpty {
                let description = DescriptionEntity(context: viewContext)
                description.text = desc
                newJob.addToDescriptions(description)
            }

            for skl in skills where !skl.isEmpty {
                let skill = SkillEntity(context: viewContext)
                skill.name = skl
                newJob.addToSkills(skill)
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
        // Check if job title and company are not empty
        guard !jobTitle.isEmpty, !company.isEmpty else {
            return false
        }
        
        // Check if start date is before end date
        if endDate < startDate {
            return false
        }
        
        return true
    }

    private func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }
}