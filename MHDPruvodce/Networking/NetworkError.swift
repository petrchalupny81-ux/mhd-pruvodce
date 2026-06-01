import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int)
    case noInternet
    case cancelled
    case timeout

    var errorDescription: String? {
        switch self {
        case .invalidURL:           return "Neplatná URL adresa."
        case .noData:               return "Server nevrátil žádná data."
        case .decodingError(let e): return "Chyba při zpracování dat: \(e.localizedDescription)"
        case .serverError(let c):   return "Chyba serveru (\(c))."
        case .noInternet:           return "Žádné připojení k internetu."
        case .cancelled:            return "Požadavek byl zrušen."
        case .timeout:              return "Požadavek vypršel."
        }
    }
}
