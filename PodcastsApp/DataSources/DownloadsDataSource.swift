//
//  DownloadsDataSource.swift
//  PodcastsApp
//
//  Created by Mahmoud Abolfotoh on 1/22/19.
//  Copyright © 2019 mahmoud gamal. All rights reserved.
//

import UIKit

class DownloadsDataSource: NSObject, UITableViewDataSource {
  fileprivate let cellId = "cellId"
  var episodes = [Episode]()
  
  override init() {
    super.init()
    episodes = UserDefaults.standard.downloadedEpisodes()
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return episodes.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
    cell.episode = episodes[indexPath.row]
    return cell
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    let episode = episodes[indexPath.row]
    episodes.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .automatic)
    UserDefaults.standard.deleteEpisode(episode: episode)
  }
}
