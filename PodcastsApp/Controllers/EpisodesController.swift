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
    
    let savedPodcasts = UserDefaults.standard.savedPodcasts()
    let hasFavorited = savedPodcasts.index(where: { $0.artistName == self.podcast.artistName && $0.trackName == self.podcast.trackName }) != nil
    
    if hasFavorited {
      navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "35 heart"), style: .plain, target: nil, action: nil)
    } else {
      navigationItem.rightBarButtonItems = [
        UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite))
      ]
    }
    
  }
  
  @objc func handleFetchSavedPodcast() {
    guard let data = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else {return}
    let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Podcast]
  }
  
  @objc func handleSaveFavorite() {
    guard let podcast = podcast else {return}
    var listOfPodcasts = UserDefaults.standard.savedPodcasts()
    listOfPodcasts.append(podcast)
    let data = NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts)
    UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
    
    showBadgeHighlight()
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "35 heart"), style: .plain, target: nil, action: nil)
    
  }
  
  fileprivate func showBadgeHighlight() {
    UIApplication.mainTabBarController()?.viewControllers?[0].tabBarItem.badgeValue = "New"
  }
  
  fileprivate func setupTableView() {
    tableView.tableFooterView = UIView()
    let nib = UINib(nibName: "EpisodeCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: cellId)
  }
  
  //MARK:- TableView
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
      print("Downloading episode .....")
      let episode = self.episodes[indexPath.row]
      let downloadEdepisodes = UserDefaults.standard.downloadedEpisodes()
      if let _ = downloadEdepisodes.firstIndex(where: {
        $0.title == episode.title && $0.author == episode.author
      }) {
        print("episode already downloaded")
        let alertController = UIAlertController(title: "Info", message: "Episode already downloaded!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alertController, animated: true)
      } else {
        UIApplication.mainTabBarController()?.viewControllers?[2].tabBarItem.badgeValue = "New"
        UserDefaults.standard.downloadEpisode(episode: episode)
        APIService.shared.downlodEpisode(episode: episode)
      }
    }
    return [downloadAction]
  }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
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
