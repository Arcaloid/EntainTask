//  Copyright © 2024 Shan Chen. All rights reserved.

import Foundation

struct Race {
    enum Category: String, Decodable {
        case greyhound = "9daef0d7-bf3c-4f50-921d-8e818c60fe61"
        case harness = "161d9be2-e909-4326-8c2c-35ed71fb460b"
        case horse = "4a2788f8-e825-4d36-9894-efd4baf1cfae"
    }

    let raceId: String
    let category: Category?
    let meetingName: String
    let raceNumber: Int
    let advertisedStart: Int
}

extension Race: Decodable {
    private enum CodingKeys: String, CodingKey {
        case raceId = "race_id"
        case categoryId = "category_id"
        case meetingName = "meeting_name"
        case raceNumber = "race_number"
        case advertisedStart = "advertised_start"
    }
    
    private enum AdvertisedStartKeys: String, CodingKey {
        case seconds
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        raceId = try container.decode(String.self, forKey: .raceId)
        category = try? container.decode(Category.self, forKey: .categoryId)
        meetingName = try container.decode(String.self, forKey: .meetingName)
        raceNumber = try container.decode(Int.self, forKey: .raceNumber)
        
        let advertisedStartContainer = try container.nestedContainer(keyedBy: AdvertisedStartKeys.self, forKey: .advertisedStart)
        advertisedStart = try advertisedStartContainer.decode(Int.self, forKey: .seconds)
    }
}

extension Race: Identifiable {
    var id: String { raceId }
}
