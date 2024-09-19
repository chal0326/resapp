//
//  ContentView.swift
//  resapp
//
//  Created by Cody Hall on 9/18/24.
//

import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var searchText = ""
    @State private var showingAddJob = false
    @State private var showingImportExport = false
    @State private var importExportAction: ImportExportAction = .export
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                JobList(searchText: searchText, showingErrorAlert: $showingErrorAlert, errorMessage: $errorMessage)
            }
            .navigationTitle("My Jobs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddJob = true }) {
                        Label("Add Job", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("Import") {
                            importExportAction = .import
                            showingImportExport = true
                        }
                        Button("Export") {
                            importExportAction = .export
                            showingImportExport = true
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddJob) {
                NavigationView {
                    JobFormView()
                }
            }
            .sheet(isPresented: $showingImportExport) {
                ImportExportView(errorMessage: $errorMessage, showingErrorAlert: $showingErrorAlert, action: importExportAction)
            }
            .alert(isPresented: $showingErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search jobs", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
        }
        .padding(.horizontal)
    }
}

struct JobList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \JobEntity.startDate, ascending: false)],
        animation: .default)
    private var job: FetchedResults<JobEntity>
    
    var searchText: String
    @Binding var showingErrorAlert: Bool
    @Binding var errorMessage: String?
    
    var filteredJob: [JobEntity] {
        if searchText.isEmpty {
            return Array(job)
        } else {
            return job.filter { job in
                job.jobTitle?.lowercased().contains(searchText.lowercased()) ?? false ||
                (job.company?.lowercased().contains(searchText.lowercased()) ?? false) ||
                job.skillsArray.contains { $0.name?.lowercased().contains(searchText.lowercased()) ?? false } ||
                job.descriptionsArray.contains { $0.text?.lowercased().contains(searchText.lowercased()) ?? false }
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredJob, id: \.self) { job in
                NavigationLink(destination: JobDetailView(job: job)) {
                    VStack(alignment: .leading) {
                        Text(job.jobTitle ?? "Unknown Title")
                            .font(.headline)
                        Text(job.company ?? "Unknown Company")
                            .font(.subheadline)
                    }
                }
            }
            .onDelete(perform: deleteJob)
        }
    }
    
    private func deleteJob(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredJob[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                errorMessage = AppError.deleteFailed(error.localizedDescription).localizedDescription
                showingErrorAlert = true
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

enum ImportExportAction {
    case `import`, export
}

struct ImportExportView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @Binding var errorMessage: String?
    @Binding var showingErrorAlert: Bool
    
    let action: ImportExportAction
    @State private var document: MessageDocument?
    @State private var isImporting = false
    @State private var isExporting = false

    var body: some View {
        VStack {
            if action == .import {
                Button("Select File to Import") {
                    isImporting = true
                }
            } else {
                Button("Export Data") {
                    exportData()
                }
            }
        }
        .navigationTitle(action == .import ? "Import Data" : "Export Data")
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile: URL = try result.get().first else { return }
                guard selectedFile.startAccessingSecurityScopedResource() else { return }
                
                defer { selectedFile.stopAccessingSecurityScopedResource() }
                
                let data = try Data(contentsOf: selectedFile)
                let job = try JSONDecoder().decode([JobData].self, from: data)
                
                for jobData in job {
                    let job = JobEntity(context: viewContext)
                    job.jobTitle = jobData.jobTitle
                    job.company = jobData.company
                    job.startDate = jobData.startDate
                    job.endDate = jobData.endDate
                    
                    for descriptionText in jobData.descriptions {
                        let description = DescriptionEntity(context: viewContext)
                        description.text = descriptionText
                        job.addToDescriptions(description)
                    }
                    
                    for skillName in jobData.skills {
                        let skill = SkillEntity(context: viewContext)
                        skill.name = skillName
                        job.addToSkills(skill)
                    }
                }
                
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                errorMessage = AppError.importFailed(error.localizedDescription).localizedDescription
                showingErrorAlert = true
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: document,
            contentType: .json,
            defaultFilename: "job_export"
        ) { result in
            if case .success = result {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    private func importData(from url: URL) {
        do {
            guard url.startAccessingSecurityScopedResource() else {
                throw AppError.importFailed("Unable to access the file.")
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            let data = try Data(contentsOf: url)
            let job = try JSONDecoder().decode([JobData].self, from: data)
            
            for jobData in job {
                let job = JobEntity(context: viewContext)
                job.jobTitle = jobData.jobTitle
                job.company = jobData.company
                job.startDate = jobData.startDate
                job.endDate = jobData.endDate
                
                for descriptionText in jobData.descriptions {
                    let description = DescriptionEntity(context: viewContext)
                    description.text = descriptionText
                    job.addToDescriptions(description)
                }
                
                for skillName in jobData.skills {
                    let skill = SkillEntity(context: viewContext)
                    skill.name = skillName
                    job.addToSkills(skill)
                }
            }
            
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            errorMessage = AppError.importFailed(error.localizedDescription).localizedDescription
            showingErrorAlert = true
        }
    }

    private func exportData() {
        do {
            let fetchRequest: NSFetchRequest<JobEntity> = JobEntity.fetchRequest()
            let job = try viewContext.fetch(fetchRequest)
            let jobData = job.map { job -> JobData in
                JobData(
                    jobTitle: job.jobTitle ?? "Unknown Title",
                    company: job.company ?? "Unknonwn Company",
                    startDate: job.startDate ?? Date(),
                    endDate: job.endDate ?? Date(),
                    descriptions: job.descriptionsArray.map { $0.text ?? "" },
                    skills: job.skillsArray.map { $0.name ?? "" }
                )
            }
            let jsonData = try JSONEncoder().encode(jobData)
            document = MessageDocument(message: String(data: jsonData, encoding: .utf8) ?? "")
            isExporting = true
        } catch {
            errorMessage = AppError.exportFailed(error.localizedDescription).localizedDescription
            showingErrorAlert = true
        }
    }
}

struct JobData: Codable {
    let jobTitle: String
    let company: String
    let startDate: Date
    let endDate: Date
    let descriptions: [String]
    let skills: [String]
}

struct MessageDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var message: String

    init(message: String) {
        self.message = message
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        message = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(message.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
