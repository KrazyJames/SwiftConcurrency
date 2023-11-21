import UIKit

enum NetworkError: Error {
    case badURL
    case decodingError
    case invalidId
}

struct Constants {
    struct Urls {
        static func equifax(userId: Int) -> URL? {
            URL(string: "https://ember-sparkly-rule.glitch.me/equifax/credit-score/\(userId)")
        }
        static func experian(userId: Int) -> URL? {
            URL(string: "https://ember-sparkly-rule.glitch.me/experian/credit-score/\(userId)")
        }
    }
}

struct CreditScore: Decodable {
    let score: Int
}

func calculateAPR(scores: [CreditScore]) -> Double {
    let sum = scores.reduce(0) { next, score in
        next + score.score
    }
    return Double((sum / scores.count) / 100)
}

// MARK: - Async Let
func getAPR(userId: Int) async throws -> Double {
    // For cancellation testing purposes
    if userId % 2 == .zero { throw NetworkError.invalidId }

    guard let equifaxUrl = Constants.Urls.equifax(userId: userId),
          let experianUrl = Constants.Urls.experian(userId: userId) else {
        throw NetworkError.badURL
    }

    // Both of the following tasks are run
    async let (equifaxData, _) = URLSession.shared.data(from: equifaxUrl)
    async let (experianData, _) = URLSession.shared.data(from: experianUrl)

    guard let equifaxCreditScore = try? JSONDecoder().decode(
        CreditScore.self,
        from: try await equifaxData
    ), let experianCreditScore = try? JSONDecoder().decode(
        CreditScore.self,
        from: try await experianData
    ) else {
        throw NetworkError.decodingError
    }

    return calculateAPR(scores: [equifaxCreditScore, experianCreditScore])
}

Task {
    try await getAPR(userId: 1)
}

// MARK: - Cancellation & Async For

let ids = [1,2,3,4,5]
var invalidIds: [Int] = .init()
/*
// This is not creating multiple concurrent processes
Task {
    for id in ids {
        do {
            // Cancellation
            try Task.checkCancellation()
            print(try await getAPR(userId: id))
        } catch {
            print(error)
            invalidIds.append(id)
        }
    }
    print(invalidIds)
}
*/

// MARK: - Task groups

typealias APRResults = [Int: Double]
typealias APRResult = (Int, Double)

func getAPRforAllUsers(ids: [Int]) async throws -> APRResults {
    var usersAPR: APRResults = .init()
    try await withThrowingTaskGroup(of: APRResult.self) { group in
        for id in ids {
            group.addTask {
                return (id, try await getAPR(userId: id))
            }
        }
        // We will have access to the groups' results as they already finished
        for try await (id, apr) in group {
            usersAPR[id] = apr
        }
    }
    return usersAPR
}

Task {
    print(try await getAPRforAllUsers(ids: ids))
}
