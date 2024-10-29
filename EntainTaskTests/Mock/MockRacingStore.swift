//  Copyright © 2024 Shan Chen. All rights reserved.

import Foundation
@testable import EntainTask

final class MockRacingStore: RacingStoreProtocol {
    var mockRaces: [Race] = []
    var mockError: Error?
    func getNextRaces() async throws -> [Race] {
        if let mockError {
            throw mockError
        } else {
            return mockRaces
        }
    }
}
