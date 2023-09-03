//
//  TopStoriesViewController.swift
//  AWilliamsHW2
//
//  Created by Austen Williams on 4/28/23.
//

import UIKit


import SafariServices
class Cell: UITableViewCell {
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var articleDescription: UILabel!
}

class TopStoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let headlines = NewsHeadlinesAPI(feed: "https://newsapi.org/v2/top-headlines?country=us&apiKey=4b4d82af0ce746e78be5adad06d33c7a")
    var topStories: [Articles] = []
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var topStoriesTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topStories.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topStoryCell = topStoriesTableView.dequeueReusableCell(withIdentifier: "topStoryCell", for: indexPath) as! Cell
        let topStory = topStories[indexPath.row]
        topStoryCell.title.text = topStory.title
        topStoryCell.articleDescription.text = topStory.description
        if let imageURL = URL(string: topStory.imageURL) {
                downloadImage(from: imageURL) { image in
                    topStoryCell.newsImage.image = image
                }
            }
        return topStoryCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let topStory = topStories[indexPath.row]

        if let url = URL(string: topStory.urlToArticle) {
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
    
    @objc func refreshData() {
        headlines.Headlines { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let articles):
                    self?.topStories = articles
                    self?.topStoriesTableView.reloadData()
                case .failure(let error):
                    print("Error fetching top headlines: \(error)")
                }
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        topStoriesTableView.delegate = self
        topStoriesTableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        topStoriesTableView.refreshControl = refreshControl
        headlines.Headlines { [weak self] result in
            switch result {
            case .success(let articles):
                DispatchQueue.main.async {
                    self?.topStories = articles
                    self?.topStoriesTableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching top headlines: \(error)")
            }
        }
    }
    
    
}

