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
                Text("Start Date: \(job.startDate.map { dateFormatter.string(from: $0) } ?? "Unknown Date")") // Safer approach
                Text("End Date: \(job.endDate != nil ? dateFormatter.string(from: job.endDate!) : "Unknown Date")") // Safely unwrap endDate
            }

            Section(header: Text("Descript")) {
                ForEach(job.descriptArray, id: \.text) { descript in // Use descriptArray directly
                    Text(descript.text ?? "No Descript") // Safely unwrap the optional
                }
            }

            Section(header: Text("Skill")) {
                ForEach(job.skillArray, id: \.name) { skill in // Use skillArray directly
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
