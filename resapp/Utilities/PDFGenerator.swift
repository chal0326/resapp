import Foundation
import PDFKit

class PDFGenerator {
    static func generateResumePDF(for job: JobEntity) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "ResApp",
            kCGPDFContextAuthor: "User"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { (context) in
            context.beginPage()
            let titleBottom = addTitle(pageRect: pageRect)
            let contentTop = addJobDetails(job: job, pageRect: pageRect, y: titleBottom + 20)
            addDescriptions(job: job, pageRect: pageRect, y: contentTop + 20)
            addSkills(job: job, pageRect: pageRect, y: pageHeight - 100)
        }

        return data
    }

    private static func addTitle(pageRect: CGRect) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont
        ]
        let attributedTitle = NSAttributedString(string: "Job Details", attributes: titleAttributes)
        let titleStringSize = attributedTitle.size()
        let titleStringRect = CGRect(x: (pageRect.width - titleStringSize.width) / 2.0,
                                     y: 36,
                                     width: titleStringSize.width,
                                     height: titleStringSize.height)
        attributedTitle.draw(in: titleStringRect)
        return titleStringRect.origin.y + titleStringRect.size.height
    }

    private static func addJobDetails(job: JobEntity, pageRect: CGRect, y: CGFloat) -> CGFloat {
        let textFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: textFont
        ]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let details = [
            "Job Title: \(job.jobTitle)",
            "Company: \(job.company)",
            "Start Date: \(dateFormatter.string(from: job.startDate))",
            "End Date: \(dateFormatter.string(from: job.endDate))"
        ]
        
        var currentY = y
        for detail in details {
            let attributedDetail = NSAttributedString(string: detail, attributes: textAttributes)
            let detailRect = CGRect(x: 72, y: currentY, width: pageRect.width - 144, height: 15)
            attributedDetail.draw(in: detailRect)
            currentY += 20
        }
        
        return currentY
    }

    private static func addDescriptions(job: JobEntity, pageRect: CGRect, y: CGFloat) -> CGFloat {
        let textFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: textFont
        ]
        
        let attributedHeader = NSAttributedString(string: "Descriptions:", attributes: [.font: UIFont.systemFont(ofSize: 14.0, weight: .bold)])
        let headerRect = CGRect(x: 72, y: y, width: pageRect.width - 144, height: 20)
        attributedHeader.draw(in: headerRect)
        
        var currentY = y + 25
        for description in job.descriptionsArray {
            let attributedDescription = NSAttributedString(string: "• \(description.text ?? "")", attributes: textAttributes)
            let descriptionRect = CGRect(x: 72, y: currentY, width: pageRect.width - 144, height: 15)
            attributedDescription.draw(in: descriptionRect)
            currentY += 20
        }
        
        return currentY
    }

    private static func addSkills(job: JobEntity, pageRect: CGRect, y: CGFloat) {
        let textFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: textFont
        ]
        
        let attributedHeader = NSAttributedString(string: "Skills:", attributes: [.font: UIFont.systemFont(ofSize: 14.0, weight: .bold)])
        let headerRect = CGRect(x: 72, y: y, width: pageRect.width - 144, height: 20)
        attributedHeader.draw(in: headerRect)
        
        let skills = job.skillsArray.map { $0.name ?? "" }.joined(separator: ", ")
        let attributedSkills = NSAttributedString(string: skills, attributes: textAttributes)
        let skillsRect = CGRect(x: 72, y: y + 25, width: pageRect.width - 144, height: 50)
        attributedSkills.draw(in: skillsRect)
    }
}