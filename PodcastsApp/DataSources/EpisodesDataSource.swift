//
//  EpisodesDataSource.swift
//  PodcastsApp
//
//  Created by Mahmoud Abolfotoh on 1/19/19.
//  Copyright © 2019 mahmoud gamal. All rights reserved.
//

import UIKit

class EpisodesDataSource: NSObject, UITableViewDataSource {
  var episodes = [Episode]()
  fileprivate var cellId = "cellId"

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return episodes.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
    let episode = episodes[indexPath.row]
    cell.episode = episode
    return cell
  }
  
  func episode(at index: Int) -> Episode {
    return episodes[index]
  }
}
