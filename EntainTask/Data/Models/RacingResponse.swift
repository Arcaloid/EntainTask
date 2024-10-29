//  Copyright © 2024 Shan Chen. All rights reserved.

import Foundation

struct RacingResponse {
    let races: [Race]
}

extension RacingResponse: Decodable {
    private typealias RaceSummaries = [String: Race]

    private enum CodingKeys: String, CodingKey {
        case data
    }
    
    private enum DataKeys: String, CodingKey {
        case raceSummaries = "race_summaries"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
        let raceSummaries = try data.decode(RaceSummaries.self, forKey: .raceSummaries)
        races = Array(raceSummaries.values)
    }
}
