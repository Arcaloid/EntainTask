//  Copyright © 2024 Shan Chen. All rights reserved.

import Foundation

protocol APIEndpoint {
    var urlString: String { get }
    var parameters: [String: String] { get }
    var headers: [String: String] { get }
    var url: URL { get }
}

extension APIEndpoint {
    var parameters: [String: String] { [:] }
    
    var headers: [String: String] { [:] }

    var url: URL {
        let url = URL(string: urlString)!
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return url }

        let queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        components.queryItems = queryItems
        return components.url!
    }
}
