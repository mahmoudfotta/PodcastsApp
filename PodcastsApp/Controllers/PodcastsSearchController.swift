//
//  PodcastsSearchController.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 9/2/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import UIKit
import Alamofire

class PodcastsSearchController: UITableViewController {
  var dataSource = PodcastsSearchDataSource()
  let cellId = "cellId"
  let searchController = UISearchController(searchResultsController: nil)
  var timer: Timer?
  let indicator = IndicatorViewController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    setupSearchBar()
  }
  
  //MARK:- setup work
  fileprivate func setupSearchBar() {
    definesPresentationContext = true
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
  }
  
  fileprivate func setupTableView() {
    tableView.tableFooterView = UIView()
    let nib = UINib(nibName: "PodcastCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: cellId)
    tableView.dataSource = dataSource
  }
  
  func podcastTapped(at indexPath: IndexPath) {
    let episodesController = EpisodesController()
    episodesController.podcast = dataSource.podcasts[indexPath.row]
    self.navigationController?.pushViewController(episodesController, animated: true)
  }
}

extension PodcastsSearchController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    podcastTapped(at: indexPath)
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 132
  }
}

extension PodcastsSearchController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    dataSource.podcasts = []
    tableView.reloadData()
    timer?.invalidate()
    if searchText.isEmpty {
      indicator.remove()
    } else {
      add(indicator)
    }
    timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false, block: {[weak self] (_) in
      APIService.shared.fetchPodcast(searchText: searchText) { (podcasts) in
        self?.dataSource.podcasts = podcasts
        self?.indicator.remove()
        self?.tableView.reloadData()
      }
    })
  }
}
