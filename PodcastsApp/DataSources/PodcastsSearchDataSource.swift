//
//  PodcastsSearchDataSource.swift
//  PodcastsApp
//
//  Created by Mahmoud Abolfotoh on 1/20/19.
//  Copyright © 2019 mahmoud gamal. All rights reserved.
//

import UIKit

class PodcastsSearchDataSource: NSObject, UITableViewDataSource {
  var podcasts = [Podcast]()
  let cellId = "cellId"

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return podcasts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
    let podcast = podcasts[indexPath.row]
    cell.podcast = podcast
    return cell
  }
}
