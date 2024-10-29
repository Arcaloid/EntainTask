//  Copyright © 2024 Shan Chen. All rights reserved.

import Foundation

struct RacingAPI: APIEndpoint {
    let urlString: String = "https://api.neds.com.au/rest/v1/racing/"
    let parameters: [String: String] = [
        "method": "nextraces",
        "count": "10"
    ]
}
