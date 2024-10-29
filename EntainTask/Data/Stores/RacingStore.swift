//  Copyright © 2024 Shan Chen. All rights reserved.

import Foundation

protocol RacingStoreProtocol {
    func getNextRaces() async throws -> [Race]
}

final class RacingStore: RacingStoreProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func getNextRaces() async throws -> [Race] {
        let response = try await apiClient.request(RacingResponse.self, endpoint: RacingAPI())
        return response.races
    }
}
