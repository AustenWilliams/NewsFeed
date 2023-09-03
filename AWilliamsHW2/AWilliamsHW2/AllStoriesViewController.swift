//
//  AllStories.swift
//  AWilliamsHW2
//
//  Created by Austen Williams on 5/1/23.
//
import SafariServices
import UIKit

class AllCell: UITableViewCell {
    
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var articleDescription: UILabel!
}

class AllStoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let stories = NewsHeadlinesAPI(feed: "https://newsapi.org/v2/everything?q=bitcoin&apiKey=4b4d82af0ce746e78be5adad06d33c7a")
    var allStories: [Articles] = []
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var allStoriesTableView: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allStories.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let allStoryCell = allStoriesTableView.dequeueReusableCell(withIdentifier: "allStoryCell", for: indexPath) as! AllCell
        let allStory = allStories[indexPath.row]
        allStoryCell.title.text = allStory.title
        allStoryCell.articleDescription.text = allStory.description
        if let imageURL = URL(string: allStory.imageURL) {
                downloadImage(from: imageURL) { image in
                    allStoryCell.newsImage.image = image
                }
            }
        return allStoryCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let allStory = allStories[indexPath.row]

        if let url = URL(string: allStory.urlToArticle) {
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
        print("refreshing")
        stories.Headlines { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let articles):
                    self?.allStories = articles
                    self?.allStoriesTableView.reloadData()
                case .failure(let error):
                    print("Error fetching top headlines: \(error)")
                }
                self?.refreshControl.endRefreshing()
            }
        }
        allStoriesTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        allStoriesTableView.delegate = self
        allStoriesTableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        allStoriesTableView.refreshControl = refreshControl
        stories.Headlines { [weak self] result in
            switch result {
            case .success(let articles):
                DispatchQueue.main.async {
                    self?.allStories = articles
                    self?.allStoriesTableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching all headlines: \(error)")
            }
        }
    }
    
    
}
