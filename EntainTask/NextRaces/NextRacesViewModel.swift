//  Copyright © 2024 Shan Chen. All rights reserved.

import Foundation
import Combine

final class NextRacesViewModel: ObservableObject {
    enum ViewState {
        case success, failure, loading
    }

    @Published private(set) var viewState: ViewState = .success
    @Published var showGreyhoundRacing = true
    @Published var showHarnessRacing = true
    @Published var showHorseRacing = true
    @Published private var races: [Race] = []
    @Published private var currentTimeInSecond: Int?
    private var loadRacesTask: Task<(), Never>?
    private var cancellables: Set<AnyCancellable> = []
    private let racingStore: RacingStoreProtocol
    
    init(racingStore: RacingStoreProtocol = RacingStore(),
         timeStore: TimeStoreProtocol = TimeStore()) {
        self.racingStore = racingStore
        timeStore.currentTimeIntervalPublisher
            .sink { [weak self] in
                self?.currentTimeInSecond = $0
            }
            .store(in: &cancellables)
    }
    
    func resetCategoryFilters() {
        showGreyhoundRacing = true
        showHarnessRacing = true
        showHorseRacing = true
    }
    
    func getDisplayRaces() -> [Race] {
        var expiredRaceCount = 0
        let filteredRaces = races.filter {
            guard countDown(for: $0) != nil else {
                expiredRaceCount += 1
                return false
            }
            switch $0.category {
            case .greyhound: return showGreyhoundRacing
            case .harness: return showHarnessRacing
            case .horse: return showHorseRacing
            default: return true
            }
        }
        if races.count - expiredRaceCount < 5 {
            loadRacesIfNeeded()
        }
        return Array(filteredRaces.prefix(5))
    }
    
    func countDown(for race: Race) -> String? {
        guard let currentTimeInSecond else { return nil }
        let countDown = race.advertisedStart - currentTimeInSecond
        switch countDown {
        // 30s
        case -59..<60:
            return "\(countDown)s"
        // 3m20s
        case 60..<300:
            let result = countDown.quotientAndRemainder(dividingBy: 60)
            let seconds = result.remainder == 0 ? "" : "\(result.remainder)s"
            return "\(result.quotient)m\(seconds)"
        // 12m
        case 60..<3600:
            return "\(countDown / 60)m"
        // 4h
        case 3600...:
            return "\(countDown / 60 / 60)h"
        default:
            return nil
        }
    }
    
    func loadRacesIfNeeded() {
        guard loadRacesTask == nil else { return }
        loadRacesTask = Task { [weak self] in
            await self?.loadRaces()
            self?.loadRacesTask = nil
        }
    }
    
    func accessibilityLabel(for race: Race) -> String {
        let countDown = countDown(for: race) ?? ""
        return "\(race.meetingName), race number \(race.raceNumber), start in \(countDown)"
    }
    
    @MainActor
    private func loadRaces() async {
        viewState = .loading
        do {
            races = try await racingStore.getNextRaces()
                .sorted(by: {
                    $0.advertisedStart < $1.advertisedStart
                })
            viewState = .success
        } catch {
            viewState = .failure
        }
    }
}
