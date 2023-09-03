//
//  SearchViewController.swift
//  AWilliamsHW2
//
//  Created by Austen Williams on 5/3/23.
//

import UIKit
import SafariServices


class SearchCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var articleDescription: UILabel!
}

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let sStories = NewsHeadlinesAPI(feed: "https://newsapi.org/v2/everything?q=bitcoin&apiKey=4b4d82af0ce746e78be5adad06d33c7a&q=")
    var searchStories: [Articles] = []


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchStories.count
    }
    

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchTableView: UITableView!
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchCell = searchTableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        let searchStory = searchStories[indexPath.row]
        searchCell.title.text = searchStory.title
        searchCell.articleDescription.text = searchStory.description
        if let imageURL = URL(string: searchStory.imageURL) {
                downloadImage(from: imageURL) { image in
                    searchCell.newsImage.image = image
                }
            }
        return searchCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let searchStory = searchStories[indexPath.row]

        if let url = URL(string: searchStory.urlToArticle) {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        } else {
            print("Invalid URL")
        }
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        
        let query = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let feed = "https://newsapi.org/v2/everything?q=\(query)&apiKey=4b4d82af0ce746e78be5adad06d33c7a"
        let sStories = NewsHeadlinesAPI(feed: feed)
        
        sStories.Headlines { [weak self] result in
            switch result {
            case .success(let articles):
                DispatchQueue.main.async {
                    self?.searchStories = articles
                    self?.searchTableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching headlines: \(error)")
            }
        }
    }

    
    
}
