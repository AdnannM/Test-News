//
//  APIError.swift
//  News
//
//  Created by Adnann Muratovic on 01.09.25.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case network(URLError)
    case httpStatus(Int, Data?)
    case decoding(DecodingError)
    case other(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "❌ Invalid URL."
        case .network(let e):
            return e.humanReadableTransport
        case .httpStatus(let code, let data):
            return APIError.describeHTTP(code: code, data: data)
        case .decoding(let e):
            return e.humanReadable
        case .other(let e):
            return "⚠️ \(e.localizedDescription)"
        }
    }

    var isTransient: Bool {
        switch self {
        case .network(let e):
            switch e.code {
            case .timedOut, .cannotFindHost, .cannotConnectToHost,
                .networkConnectionLost, .notConnectedToInternet,
                .dnsLookupFailed:
                return true
            default: return false
            }
        case .httpStatus(let code, _):
            return (500...599).contains(code)
        default:
            return false
        }
    }

    var isUnauthorized: Bool {
        if case .httpStatus(401, _) = self { return true }
        return false
    }

    static func map(_ error: Error) -> APIError {
        if let api = error as? APIError { return api }
        if let url = error as? URLError { return .network(url) }
        if let dec = error as? DecodingError { return .decoding(dec) }
        return .other(error)
    }

    private static func describeHTTP(code: Int, data: Data?) -> String {
        var base = "🌐 HTTP \(code)"
        switch code {
        case 400: base += " – Bad Request"
        case 401: base += " – Unauthorized"
        case 403: base += " – Forbidden"
        case 404: base += " – Not Found"
        case 500: base += " – Server Error"
        default: break
        }
        if let d = data, let msg = String(data: d, encoding: .utf8),
            !msg.isEmpty
        {
            base += "\nServer says: \(msg)"
        }
        return base
    }
}

// MARK: - Error messages for Decoding/Transport

extension DecodingError {
    fileprivate var humanReadable: String {
        switch self {
        case .keyNotFound(let key, let ctx):
            return
                "🔑 Missing key '\(key.stringValue)' at path: \(ctx.pathString)"
        case .typeMismatch(let type, let ctx):
            return "📐 Type mismatch for \(type) at path: \(ctx.pathString)"
        case .valueNotFound(let type, let ctx):
            return "❓ Missing value for \(type) at path: \(ctx.pathString)"
        case .dataCorrupted(let ctx):
            return "💾 Data corrupted: \(ctx.debugDescription)"
        @unknown default:
            return "Decoding failed."
        }
    }
}

extension DecodingError.Context {
    fileprivate var pathString: String {
        codingPath.map { $0.stringValue }.joined(separator: " → ")
    }
}

extension URLError {
    fileprivate var humanReadableTransport: String {
        switch code {
        case .notConnectedToInternet: return "📡 No internet connection."
        case .timedOut: return "⏱️ The request timed out."
        case .cannotFindHost: return "🌍 Cannot find host."
        case .cannotConnectToHost: return "🚫 Cannot connect to server."
        case .networkConnectionLost: return "🔌 Network connection was lost."
        default: return localizedDescription
        }
    }
}
