import Foundation

enum AppError: Error, LocalizedError {
    case importFailed(String)
    case exportFailed(String)
    case saveFailed(String)
    case deleteFailed(String)

    var errorDescription: String? {
        switch self {
        case .importFailed(let reason):
            return "Import failed: \(reason)"
        case .exportFailed(let reason):
            return "Export failed: \(reason)"
        case .saveFailed(let reason):
            return "Save failed: \(reason)"
        case .deleteFailed(let reason):
            return "Delete failed: \(reason)"
        }
    }
}