import SwiftUI
import CoreData

struct AddJobView: View {
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

            Section(header: Text("Descript")) {
                ForEach(descript.indices, id: \.self) { index in
                    HStack {
                        TextField("Descript", text: $descript[index])
                        if descript.count > 1 {
                            Button(action: {
                                descript.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                Button(action: {
                    descript.append("")
                }) {
                    Label("Add Descript", systemImage: "plus")
                }
            }

            Section(header: Text("Skill")) {
                ForEach(skill.indices, id: \.self) { index in
                    HStack {
                        TextField("Skill", text: $skill[index])
                        if skill.count > 1 {
                            Button(action: {
                                skill.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                Button(action: {
                    skill.append("")
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

            for desc in descript where !desc.isEmpty {
                let descript = DescriptEntity(context: viewContext)
                descript.text = desc
                newJob.addToDescript(descript)
            }

            for skl in skill where !skl.isEmpty {
                let skill = SkillEntity(context: viewContext)
                skill.name = skl
                newJob.addToSkill(skill)
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