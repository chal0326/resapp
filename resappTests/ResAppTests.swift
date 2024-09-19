import XCTest
@testable import resapp

class ResAppTests: XCTestCase {
    var persistenceController: PersistenceController!
    var viewContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        viewContext = persistenceController.container.viewContext
    }

    override func tearDownWithError() throws {
        persistenceController = nil
        viewContext = nil
    }

    func testCreateJob() throws {
        let job = JobEntity(context: viewContext)
        job.jobTitle = "Software Developer"
        job.company = "Tech Co"
        job.startDate = Date()
        job.endDate = Date().addingTimeInterval(86400 * 365)

        XCTAssertNoThrow(try viewContext.save())

        let fetchRequest: NSFetchRequest<JobEntity> = JobEntity.fetchRequest()
        let results = try viewContext.fetch(fetchRequest)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.jobTitle, "Software Developer")
        XCTAssertEqual(results.first?.company, "Tech Co")
    }

    func testDeleteJob() throws {
        let job = JobEntity(context: viewContext)
        job.jobTitle = "Test Job"
        try viewContext.save()

        viewContext.delete(job)
        try viewContext.save()

        let fetchRequest: NSFetchRequest<JobEntity> = JobEntity.fetchRequest()
        let results = try viewContext.fetch(fetchRequest)

        XCTAssertEqual(results.count, 0)
    }

    func testJobValidation() {
        let job = JobEntity(context: viewContext)
        job.jobTitle = "SW"
        job.company = "C"
        job.startDate = Date()
        job.endDate = Date().addingTimeInterval(-86400)

        XCTAssertFalse(job.isValid)

        job.jobTitle = "Software Developer"
        job.company = "Tech Co"
        job.endDate = Date().addingTimeInterval(86400)

        XCTAssertTrue(job.isValid)
    }
}