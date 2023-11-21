//
//  ContentView.swift
//  GettingStartedAsyncAwait
//
//  Created by Mohammad Azam on 7/9/21.
//

import SwiftUI

struct CurrentDate: Decodable, Identifiable {
    let id = UUID()
    let date: String
    
    private enum CodingKeys: String, CodingKey {
        case date = "date"
    }
}

struct WebService {
    static func fetch<T: Decodable>() async throws -> T {
        guard let url = URL(string: "https://ember-sparkly-rule.glitch.me/current-date") else {
            fatalError("Invalid URL")
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

@Observable
class ContentViewModel {
    var currentDates: [CurrentDate] = .init()

    /// All functions that will use Swift Concurrency
    /// may use _async_ keyword
    /// to indicate that it will await for a task to finish to continue
    /// and suspend the work until it is done
    private func getDate() async throws -> CurrentDate? {
        try await WebService.fetch()
    }

    @MainActor
    func populateDates() async {
        do {
            guard let newDate = try await getDate() else {
                return
            }
            currentDates.append(newDate)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

struct ContentView: View {
    private var model: ContentViewModel = .init()

    var body: some View {
        NavigationView {
            List(model.currentDates) { date in
                Text(date.date)
            }
            .listStyle(.plain)
            .navigationTitle("Dates")
            .navigationBarItems(trailing: Button(action: {
                Task {
                    await model.populateDates()
                }
            }, label: {
                Image(systemName: "arrow.clockwise.circle")
            }))
        }
        .task {
            await model.populateDates()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
