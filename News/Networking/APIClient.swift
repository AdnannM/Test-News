//
//  APIClient.swift
//  News
//
//  Created by Adnann Muratovic on 01.09.25.
//

import Foundation

private enum APIClientError: Error {
    case nonHTTPResponse
    case emptyBody
}

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

final class APIClient {
    static let shared = APIClient()

    // MARK: - Init with configured session/codec
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        let cfg = URLSessionConfiguration.default
        cfg.requestCachePolicy = .useProtocolCachePolicy
        cfg.urlCache = .shared
        cfg.timeoutIntervalForRequest = 20
        cfg.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: cfg)

        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        self.decoder = dec

        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        self.encoder = enc
    }

    // MARK: - Core request
    @discardableResult
    func request<T: Decodable>(
        _ type: T.Type,
        method: HTTPMethod,
        urlString: String,
        body: Encodable? = nil,
        headers: [String: String] = [:]
    ) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body = body {
            req.httpBody = try encoder.encode(AnyEncodable(body))
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }

        do {
            let (data, response) = try await session.data(for: req)
            guard let http = response as? HTTPURLResponse else {
                throw APIError.other(APIClientError.nonHTTPResponse)
            }

            guard (200...299).contains(http.statusCode) else {
                throw APIError.httpStatus(http.statusCode, data)
            }

            let expectsEmpty =
                http.statusCode == 204 || http.statusCode == 205
                || req.httpMethod == "HEAD" || T.self == EmptyResponse.self

            if expectsEmpty {
                if T.self == EmptyResponse.self { return EmptyResponse() as! T }
                if data.isEmpty { throw APIClientError.emptyBody }
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch let de as DecodingError {
                throw APIError.decoding(de)
            }
        } catch let e as URLError {
            throw APIError.network(e)
        } catch {
            throw APIError.other(error)
        }
    }

    func get<T: Decodable>(_ type: T.Type, from url: String) async throws -> T {
        try await request(type, method: .GET, urlString: url)
    }
}

struct AnyEncodable: Encodable {
    private let encodeImpl: (Encoder) throws -> Void
    init(_ value: Encodable) { self.encodeImpl = value.encode }
    func encode(to encoder: Encoder) throws { try encodeImpl(encoder) }
}

struct EmptyResponse: Decodable {}
