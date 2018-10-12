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
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    episodes = UserDefaults.standard.downloadedEpisodes()
    tableView.reloadData()
  }
  
  //MARK:- setup
  
  fileprivate func setupTableView() {
    let nib = UINib(nibName: "EpisodeCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: cellId)
  }
  
  //MARK:= UITableview
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
