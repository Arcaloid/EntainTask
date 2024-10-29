//  Copyright © 2024 Shan Chen. All rights reserved.

import Foundation
import Combine

protocol TimeStoreProtocol {
    var currentTimeIntervalPublisher: AnyPublisher<Int, Never> { get }
}

final class TimeStore: TimeStoreProtocol {
    var currentTimeIntervalPublisher: AnyPublisher<Int, Never> {
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .map { _ in Int(Date().timeIntervalSince1970) }
            .eraseToAnyPublisher()
    }
}
