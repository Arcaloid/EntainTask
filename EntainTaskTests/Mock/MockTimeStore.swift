//  Copyright © 2024 Shan Chen. All rights reserved.

import Foundation
import Combine
@testable import EntainTask

final class MockTimeStore: TimeStoreProtocol {
    var mockCurrentTimeInterval = PassthroughSubject<Int, Never>()
    var currentTimeIntervalPublisher: AnyPublisher<Int, Never> {
        mockCurrentTimeInterval.eraseToAnyPublisher()
    }
}
