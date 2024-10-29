//  Copyright © 2024 Shan Chen. All rights reserved.

import Foundation
import Combine

protocol APIClientProtocol {
    func request<T: Decodable>(_ responseType: T.Type, endpoint: APIEndpoint) async throws -> T
    func request<T: Decodable>(
        _ responseType: T.Type,
        endpoint: APIEndpoint,
        completion: @escaping (Result<T, Error>) -> ()
    )
    func requestPublisher<T: Decodable>(
        _ responseType: T.Type,
        endpoint: APIEndpoint
    ) -> AnyPublisher<T, Error>
}

struct APIClient: APIClientProtocol {
    func request<T: Decodable>(_ responseType: T.Type, endpoint: APIEndpoint) async throws -> T {
        var urlRequest = URLRequest(url: endpoint.url)
        for header in endpoint.headers {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func request<T: Decodable>(
        _ responseType: T.Type,
        endpoint: APIEndpoint,
        completion: @escaping (Result<T, Error>) -> ()
    ) {
        Task {
            do {
                let responseObject = try await request(responseType, endpoint: endpoint)
                completion(.success(responseObject))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func requestPublisher<T: Decodable>(
        _ responseType: T.Type,
        endpoint: APIEndpoint
    ) -> AnyPublisher<T, Error> {
        Future { promise in
            request(responseType, endpoint: endpoint) { result in
                switch result {
                case let .success(responseObject):
                    promise(.success(responseObject))
                case let .failure(error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
