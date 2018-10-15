//
//  DownloadsController.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 10/6/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import UIKit

class DownloadsController: UITableViewController {
  
  fileprivate let cellId = "cellId"
  var episodes = UserDefaults.standard.downloadedEpisodes()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    setupObserver()
  }
  
  fileprivate func setupObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadCompleted), name: .downloadComplete, object: nil)
  }
  
  @objc fileprivate func handleDownloadCompleted(notification: Notification) {
    guard let episodeDownloadComplete = notification.object as? APIService.EpisodeDownloadCompleteTuple else {return}
    guard let index = self.episodes.firstIndex(where: {
      $0.title == episodeDownloadComplete.episodeTitle
    }) else {return}
    self.episodes[index].fileUrl = episodeDownloadComplete.fileUrl
  }
  
  @objc fileprivate func handleDownloadProgress(notification: Notification) {
    guard let userInfo = notification.userInfo as? [String: Any] else {return}
    guard let progress = userInfo["progress"] as? Double else {return}
    guard let title = userInfo["title"] as? String else {return}
    
    guard let index = self.episodes.firstIndex(where: {
      $0.title == title
    }) else {return}
    
    guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else {return}
    cell.progressLabel.isHidden = false
    cell.progressLabel.text = "\(Int(progress*100))%"
    if progress == 1 {
      cell.progressLabel.isHidden = true
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    episodes = UserDefaults.standard.downloadedEpisodes()
    tableView.reloadData()
    UIApplication.mainTabBarController()?.viewControllers?[2].tabBarItem.badgeValue = nil
  }
  
  //MARK:- setup
  
  fileprivate func setupTableView() {
    let nib = UINib(nibName: "EpisodeCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: cellId)
  }
  
  //MARK:= UITableview
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let episode = episodes[indexPath.row]
    if episode.fileUrl != nil {
      UIApplication.mainTabBarController()?.maximizeDetailsView(episode: episode, playListEpisodes: self.episodes)
    } else {
      let alertController = UIAlertController(title: "File url not found", message: "Can't find local file, play using stream url instead", preferredStyle: .actionSheet)
      alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
        UIApplication.mainTabBarController()?.maximizeDetailsView(episode: episode, playListEpisodes: self.episodes)
      }))
      alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
      present(alertController, animated: true)
    }
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    let episode = self.episodes[indexPath.row]
    episodes.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .automatic)
    UserDefaults.standard.deleteEpisode(episode: episode)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return episodes.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
    cell.episode = episodes[indexPath.row]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 134
  }
}
