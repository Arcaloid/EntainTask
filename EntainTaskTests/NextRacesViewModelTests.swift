//  Copyright © 2024 Shan Chen. All rights reserved.

import XCTest
import Combine
@testable import EntainTask

final class NextRacesViewModelTests: XCTestCase {
    private var viewModel: NextRacesViewModel!
    private var mockRacingStore: MockRacingStore!
    private var mockTimeStore: MockTimeStore!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
        mockRacingStore = MockRacingStore()
        mockTimeStore = MockTimeStore()
        viewModel = NextRacesViewModel(racingStore: mockRacingStore, timeStore: mockTimeStore)
    }
    
    func testResetCategoryFilters() {
        viewModel.showGreyhoundRacing = false
        viewModel.showHarnessRacing = false
        viewModel.showHorseRacing = false
        viewModel.resetCategoryFilters()
        XCTAssertTrue(viewModel.showGreyhoundRacing)
        XCTAssertTrue(viewModel.showHarnessRacing)
        XCTAssertTrue(viewModel.showHorseRacing)
    }
    
    func testDisplayAllRaces() {
        mockRacingStore.mockRaces = MockData.mockRaces
        mockTimeStore.mockCurrentTimeInterval.send(1730110000)
        let expectation = expectation(description: "load races")
        viewModel.$viewState
            .dropFirst()
            .filter { $0 == .success }
            .prefix(1)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        viewModel.loadRacesIfNeeded()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(viewModel.getDisplayRaces().count, 5)
    }
    
    func testHideExpiredRaces() {
        mockRacingStore.mockRaces = MockData.mockRaces
        mockTimeStore.mockCurrentTimeInterval.send(1730115480)
        let expectation = expectation(description: "load races")
        viewModel.$viewState
            .dropFirst()
            .filter { $0 == .success }
            .prefix(1)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        viewModel.loadRacesIfNeeded()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(viewModel.getDisplayRaces().count, 4)
    }
    
    func testDisplayGreyhoundRacing() {
        viewModel.showGreyhoundRacing = true
        viewModel.showHarnessRacing = false
        viewModel.showHorseRacing = false
        mockRacingStore.mockRaces = MockData.mockRaces
        mockTimeStore.mockCurrentTimeInterval.send(1730110000)
        let expectation = expectation(description: "load races")
        viewModel.$viewState
            .dropFirst()
            .filter { $0 == .success }
            .prefix(1)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        viewModel.loadRacesIfNeeded()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(viewModel.getDisplayRaces().count, 5)
    }
    
    func testDisplayHarnessRacing() {
        viewModel.showGreyhoundRacing = false
        viewModel.showHarnessRacing = true
        viewModel.showHorseRacing = false
        mockRacingStore.mockRaces = MockData.mockRaces
        mockTimeStore.mockCurrentTimeInterval.send(1730110000)
        let expectation = expectation(description: "load races")
        viewModel.$viewState
            .dropFirst()
            .filter { $0 == .success }
            .prefix(1)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        viewModel.loadRacesIfNeeded()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(viewModel.getDisplayRaces().count, 1)
    }
    
    func testDisplayHorseRacing() {
        viewModel.showGreyhoundRacing = false
        viewModel.showHarnessRacing = false
        viewModel.showHorseRacing = true
        mockRacingStore.mockRaces = MockData.mockRaces
        mockTimeStore.mockCurrentTimeInterval.send(1730110000)
        let expectation = expectation(description: "load races")
        viewModel.$viewState
            .dropFirst()
            .filter { $0 == .success }
            .prefix(1)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        viewModel.loadRacesIfNeeded()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(viewModel.getDisplayRaces().count, 1)
    }
    
    func testLoadRacesWhenDisplayLessThanFive() {
        mockRacingStore.mockRaces = MockData.mockRaces
        mockTimeStore.mockCurrentTimeInterval.send(1730115480)
        var expectation = expectation(description: "load races")
        viewModel.$viewState
            .dropFirst()
            .filter { $0 == .success }
            .prefix(1)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        viewModel.loadRacesIfNeeded()
        wait(for: [expectation], timeout: 1)
        
        expectation = self.expectation(description: "get display races")
        viewModel.$viewState
            .dropFirst()
            .filter { $0 == .success }
            .prefix(1)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        XCTAssertEqual(viewModel.getDisplayRaces().count, 4)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(viewModel.getDisplayRaces().count, 4)
    }
    
    func testCountDown() throws {
        mockRacingStore.mockRaces = MockData.mockRaces
        mockTimeStore.mockCurrentTimeInterval.send(1730114820)
        let expectation = expectation(description: "load races")
        viewModel.$viewState
            .dropFirst()
            .filter { $0 == .success }
            .prefix(1)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        viewModel.loadRacesIfNeeded()
        wait(for: [expectation], timeout: 1)
        
        let race = try XCTUnwrap(viewModel.getDisplayRaces().first)
        mockTimeStore.mockCurrentTimeInterval.send(1730114879)
        XCTAssertEqual(viewModel.countDown(for: race), "-59s")
        
        mockTimeStore.mockCurrentTimeInterval.send(1730114761)
        XCTAssertEqual(viewModel.countDown(for: race), "59s")
        
        mockTimeStore.mockCurrentTimeInterval.send(1730114760)
        XCTAssertEqual(viewModel.countDown(for: race), "1m")
        
        mockTimeStore.mockCurrentTimeInterval.send(1730114710)
        XCTAssertEqual(viewModel.countDown(for: race), "1m50s")
        
        mockTimeStore.mockCurrentTimeInterval.send(1730111200)
        XCTAssertEqual(viewModel.countDown(for: race), "1h")
    }
    
    func testViewStateLoadSuccess() {
        var viewStates = [NextRacesViewModel.ViewState]()
        mockRacingStore.mockRaces = MockData.mockRaces
        let expectation = expectation(description: "load races")
        viewModel.$viewState
            .sink {
                viewStates.append($0)
                if viewStates.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        viewModel.loadRacesIfNeeded()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(viewStates, [.success, .loading, .success])
    }
    
    func testViewStateLoadFailed() {
        var viewStates = [NextRacesViewModel.ViewState]()
        mockRacingStore.mockError = NSError()
        let expectation = expectation(description: "load races")
        viewModel.$viewState
            .sink {
                viewStates.append($0)
                if viewStates.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        viewModel.loadRacesIfNeeded()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(viewStates, [.success, .loading, .failure])
    }
}
