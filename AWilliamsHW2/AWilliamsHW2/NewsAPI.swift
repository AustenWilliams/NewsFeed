//
//  NewsAPI.swift
//  AWilliamsHW2
//
//  Created by Austen Williams on 4/30/23.
//

import Foundation


class NewsHeadlinesAPI{
    
    private var feed: String
    
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init(feed: String) { self.feed = feed}
    
    public func Headlines(completion: @escaping (Result<[Articles], Error>) -> Void) {
        guard let feedURL = URL(string: feed) else {
            return
        }
        let request = URLRequest(url: feedURL)
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let data = data else { return }
            
            print(data)
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let articlesJson = json["articles"] as? [[String: Any]] {
                    let articles = articlesJson.compactMap { articleJson -> Articles? in
                        guard let title = articleJson["title"] as? String,
                              let description = articleJson["description"] as? String,
                              let imageURL = articleJson["urlToImage"] as? String,
                              let urlToArticle = articleJson["url"] as? String,
                              let sourceJson = articleJson["source"] as? [String: Any],
                              let name = sourceJson["name"] as? String else {
                            return nil
                        }
                        
                        let source = Source(name: name)
                        return Articles(title: title, description: description, imageURL: imageURL, urlToArticle: urlToArticle, source: source)
                    }
                    
                    let newsResponse = NewsAPIResponse(articles: articles)
                    completion(.success(newsResponse.articles))
                } else {
                    completion(.failure(error!))
                }
            } catch SerializationError.missing(let msg) {
                print("Missing \(msg)")
            } catch SerializationError.invalid(let msg, let data) {
                print("Invalid \(msg): \(data)")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

struct NewsAPIResponse: Codable {
    let articles: [Articles]
}

struct Articles: Codable {
    let title: String
    let description: String
    let imageURL: String
    let urlToArticle: String
    let source: Source
}

struct Source: Codable {
    let name: String
}
