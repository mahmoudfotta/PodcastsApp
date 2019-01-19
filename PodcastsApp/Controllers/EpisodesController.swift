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
  var dataSource = EpisodesDataSource()
  var delegate: EpisodesTableViewDelegate!
  
  var podcast: Podcast! {
    didSet {
      navigationItem.title = podcast.trackName
      fetchEpisodes()
    }
  }
  
  fileprivate func fetchEpisodes() {
    guard let feedUrl = podcast.feedUrl else {return}
    APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
      self.dataSource.episodes = episodes
      DispatchQueue.main.async {
        self.delegate.episodes = self.dataSource.episodes
        self.tableView.reloadData()
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    setupNavigationBarButtons()
  }
  
  //MARK:- setup work
  
  fileprivate func setupTableView() {
    tableView.tableFooterView = UIView()
    let nib = UINib(nibName: "EpisodeCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: cellId)
    tableView.dataSource = dataSource
    delegate = EpisodesTableViewDelegate(alreadyDownloadedAction: { [weak self] in
      self?.alreadyDownloadedAlert()
    })
    tableView.delegate = delegate
  }
  
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
  
  func alreadyDownloadedAlert() {
    let alertController = UIAlertController(title: "Info", message: "Episode already downloaded!", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Ok", style: .default))
    self.present(alertController, animated: true)
  }
}
