//  Copyright © 2024 Shan Chen. All rights reserved.

import SwiftUI

struct NextRacesView: View {
    @StateObject private var viewModel: NextRacesViewModel = NextRacesViewModel()
    
    var body: some View {
        VStack {
            switch viewModel.viewState {
            case .success:
                listView
            case .failure:
                failureView
            case .loading:
                ProgressView()
                    .controlSize(.extraLarge)
            }
        }
        .onAppear {
            viewModel.loadRacesIfNeeded()
        }
    }
    
    @ViewBuilder
    private var listView: some View {
        List(viewModel.getDisplayRaces()) { race in
            VStack(alignment: .leading) {
                HStack {
                    Text(race.meetingName)
                    Spacer()
                    if let countDown = viewModel.countDown(for: race) {
                        Text(countDown)
                    }
                }
                Text("Race number: \(race.raceNumber)")
            }
            .accessibilityElement()
            .accessibilityLabel(viewModel.accessibilityLabel(for: race))
        }
        
        HStack {
            Toggle("Greyhound", isOn: $viewModel.showGreyhoundRacing)
                .toggleStyle(.button)
            Toggle("Harness", isOn: $viewModel.showHarnessRacing)
                .toggleStyle(.button)
            Toggle("Horse", isOn: $viewModel.showHorseRacing)
                .toggleStyle(.button)
        }
        
        Button("Show all races") {
            viewModel.resetCategoryFilters()
        }
        .padding()
    }
    
    @ViewBuilder
    private var failureView: some View {
        Text("Load error")
        Button("Try again") {
            viewModel.loadRacesIfNeeded()
        }
    }
}

#Preview {
    NextRacesView()
}
