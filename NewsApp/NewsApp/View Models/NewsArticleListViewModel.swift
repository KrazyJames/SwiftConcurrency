//
//  NewsArticleListViewModel.swift
//  NewsApp
//
//  Created by Mohammad Azam on 6/30/21.
//

import Foundation

@MainActor
class NewsArticleListViewModel: ObservableObject {
    
    @Published var newsArticles: [NewsArticleViewModel] = .init()

    func getNewsBy(sourceId: String) async {
        do {
            let articles = try await Webservice().fetchNews(by: sourceId, url: Constants.Urls.topHeadlines(by: sourceId))
            newsArticles = articles.map(NewsArticleViewModel.init)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

struct NewsArticleViewModel {
    
    let id = UUID()
    fileprivate let newsArticle: NewsArticle
    
    var title: String {
        newsArticle.title
    }
    
    var description: String {
        newsArticle.description ?? ""
    }
    
    var author: String {
        newsArticle.author ?? ""
    }
    
    var urlToImage: URL? {
        URL(string: newsArticle.urlToImage ?? "")
    }
    
}
