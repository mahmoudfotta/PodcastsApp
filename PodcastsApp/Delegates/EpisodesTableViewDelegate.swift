//
//  EpisodesTableViewDelegate.swift
//  PodcastsApp
//
//  Created by Mahmoud Abolfotoh on 1/19/19.
//  Copyright © 2019 mahmoud gamal. All rights reserved.
//

import UIKit

class EpisodesTableViewDelegate: NSObject, UITableViewDelegate {
  var episodes: [Episode]?
  var alreadyDownloadedAction: (() -> Void)?
  
  init(alreadyDownloadedAction: @escaping (() -> Void)) {
    self.alreadyDownloadedAction = alreadyDownloadedAction
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
      self.downloadEpisode(at: indexPath)
    }
    return [downloadAction]
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    activityIndicator.color = .darkGray
    activityIndicator.startAnimating()
    return activityIndicator
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return episodes?.isEmpty ?? true ? 200 : 0
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let episodes = episodes else { return }
    let episode = episodes[indexPath.row]
    let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
    mainTabBarController?.maximizeDetailsView(episode: episode, playListEpisodes: episodes)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 134
  }
  
  func downloadEpisode(at indexPath: IndexPath) {
    guard let episode = self.episodes?[indexPath.row] else { return }
    let downloadEdepisodes = UserDefaults.standard.downloadedEpisodes()
    if let _ = downloadEdepisodes.firstIndex(where: {
      $0.title == episode.title && $0.author == episode.author
    }) {
      print("episode already downloaded")
      self.alreadyDownloadedAction?()
    } else {
      UIApplication.mainTabBarController()?.viewControllers?[2].tabBarItem.badgeValue = "New"
      UserDefaults.standard.downloadEpisode(episode: episode)
      APIService.shared.downlodEpisode(episode: episode)
    }
  }
}
