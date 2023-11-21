import UIKit

enum NetworkError: Error {
    case badUrl
    case noData
    case decoding
}

struct Post: Decodable {
    let title: String
}

func getPosts(completion: @escaping (Result<[Post], NetworkError>) -> Void) {
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
        return completion(.failure(.badUrl))
    }

    URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            return completion(.failure(.noData))
        }
        guard let posts = try? JSONDecoder().decode([Post].self, from: data) else {
            return completion(.failure(.decoding))
        }
        return completion(.success(posts))
    }.resume()
}

getPosts { result in
    switch result {
    case .success(let success):
        DispatchQueue.main.async {
            print(success.count)
        }
    case .failure(let failure):
        DispatchQueue.main.async {
            print(failure.localizedDescription)
        }
    }
}

func getPosts() async throws -> [Post] {
    try await withCheckedThrowingContinuation { continuation in
        getPosts { result in
            switch result {
            case .success(let posts):
                continuation.resume(returning: posts)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
}

Task {
    do {
        try await getPosts()
    } catch {
        print(error.localizedDescription)
    }
}

