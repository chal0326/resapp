import SwiftUI
import CoreData

struct JobDetailView: View {
    @ObservedObject var job: JobEntity
    @State private var showingEditView: Bool = false
    @State private var showingShareSheet: Bool = false
    @State private var pdfData: Data? = nil

    var body: some View {
        List {
            Section(header: Text("Job Details")) {
                Text("Title: \(job.jobTitle ?? "Unknown Title")") // Safely unwrap jobTitle
                Text("Company: \(job.company ?? "Unknown Company")") // Safely unwrap company
                Text("Start Date: \(job.startDate != nil ? dateFormatter.string(from: job.startDate!) : "Unknown Date")") // Safely unwrap startDate
                Text("End Date: \(job.endDate != nil ? dateFormatter.string(from: job.endDate!) : "Unknown Date")") // Safely unwrap endDate
            }

            Section(header: Text("Descriptions")) {
                ForEach(job.descriptionsArray, id: \.text) { description in // Use descriptionsArray directly
                    Text(description.text ?? "No Description") // Safely unwrap the optional
                }
            }

            Section(header: Text("Skills")) {
                ForEach(job.skillsArray, id: \.name) { skill in // Use skillsArray directly
                    Text(skill.name ?? "No Skill") // Safely unwrap the optional
                }
            }
        }
        .navigationTitle(job.jobTitle ?? "Job Details") // Safely unwrap jobTitle for navigation title
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditView = true
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Export PDF") {
                    exportPDF()
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            NavigationView {
                JobFormView(job: job)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let pdfData = pdfData {
                ActivityViewController(activityItems: [pdfData])
            }
        }
    }

    private func exportPDF() {
        pdfData = PDFGenerator.generateResumePDF(for: job)
        showingShareSheet = true
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

// Extend JobEntity to provide sorted arrays
extension JobEntity {
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
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}
