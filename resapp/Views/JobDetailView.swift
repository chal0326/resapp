import SwiftUI
import CoreData

struct JobDetailView: View {
    @ObservedObject var job: JobEntity
    @State private var showingEditView = false
    @State private var showingShareSheet = false
    @State private var pdfData: Data?

    var body: some View {
        List {
            Section(header: Text("Job Details")) {
                Text("Title: \(job.jobTitle)")
                Text("Company: \(job.company)")
                Text("Start Date: \(job.startDate, formatter: dateFormatter)")
                Text("End Date: \(job.endDate, formatter: dateFormatter)")
            }

            Section(header: Text("Descriptions")) {
                ForEach(job.descriptionsArray, id: \.self) { description in
                    Text(description)
                }
            }

            Section(header: Text("Skills")) {
                ForEach(job.skillsArray, id: \.self) { skill in
                    Text(skill)
                }
            }
        }
        .navigationTitle(job.jobTitle)
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