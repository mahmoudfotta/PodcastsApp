//
//  EpisodesController.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 9/5/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    
    fileprivate var cellId = "cellId"
    
    var podcast: Podcast! {
        didSet {
            navigationItem.title = podcast.trackName
            fetchEpisodes()
        }
    }
    
    fileprivate func fetchEpisodes() {
        guard let feedUrl = podcast.feedUrl else {return}
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
 
    
    var episodes = [Episode]()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBarButtons()
    }
    
    //MARK:- setup work
    
    fileprivate func setupNavigationBarButtons() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite)),
            UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSavedPodcast))
        ]
    }
    
    @objc func handleFetchSavedPodcast() {
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else {return}
        let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Podcast]
        savedPodcasts?.forEach({ (podcast) in
            print(podcast.trackName, podcast.artistName)
        })
        
    }
    
    @objc func handleSaveFavorite() {
        guard let podcast = podcast else {return}
        var listOfPodcasts = UserDefaults.standard.savedPodcasts()
        listOfPodcasts.append(podcast)
        let data = NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts)
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
    }
    
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    //MARK:- TableView
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.color = .darkGray
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBarController?.maximizeDetailsView(episode: episode, playListEpisodes: episodes)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
}
