//
//  RandomImageListViewModel.swift
//  RandomQuoteAndImages
//
//  Created by Jaime Escobar on 22/11/23.
//

import Foundation
import UIKit.UIImage


@Observable
final class RandomImageListViewModel {

    private let webService: Webservice
    var images: [RandomImageViewModel] = .init()

    init(webService: Webservice = Webservice()) {
        self.webService = webService
    }

    @MainActor
    func getRandomImages(ids: [Int]) async {
        images.removeAll()
        do {
            /* This will await for all the images to load in order to present them
             self.images = try await webService.getRandomImages(ids: ids).map(RandomImageViewModel.init)
             */
            // This is going to load once the tuple is completed for each element
            try await withThrowingTaskGroup(of: (Int, RandomImage).self) { group in
                for id in ids {
                    group.addTask { [self] in
                        return (id, try await webService.getRandomImage(id: id))
                    }
                }
                for try await (_, image) in group {
                    images.append(.init(randomImage: image))
                }
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

struct RandomImageViewModel: Identifiable {
    let id = UUID()
    let randomImage: RandomImage

    var image: UIImage? {
        UIImage(data: randomImage.image)
    }

    var quote: String {
        randomImage.quote.content
    }
}
