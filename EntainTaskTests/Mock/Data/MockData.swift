//  Copyright © 2024 Shan Chen. All rights reserved.

import Foundation
@testable import EntainTask

enum MockData {
    static var mockRaces: [Race] {
        let racingResponse: RacingResponse = loadMockResponse(jsonFile: "nextRacesResponse")
        return racingResponse.races
    }
    
    private static func loadMockResponse<T: Decodable>(jsonFile: String) -> T {
        let path = Bundle(for: MockClass.self).path(
            forResource: jsonFile, ofType: "json"
        )!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        return try! JSONDecoder().decode(T.self, from: data)
    }
}

private final class MockClass {}
