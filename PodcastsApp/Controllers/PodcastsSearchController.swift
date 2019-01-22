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
  var delegate: PodcastsSearchTableViewDelegate!
  var timer: Timer?

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
    delegate = PodcastsSearchTableViewDelegate(searchController: searchController, cellTapped: {[weak self] (indexPath) in
      self?.podcastTapped(at: indexPath)
    })
    tableView.delegate = delegate
  }
  
  func podcastTapped(at indexPath: IndexPath) {
    let episodesController = EpisodesController()
    episodesController.podcast = dataSource.podcasts[indexPath.row]
    self.navigationController?.pushViewController(episodesController, animated: true)
  }
}

extension PodcastsSearchController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    dataSource.podcasts = []
    tableView.reloadData()
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false, block: { (_) in
      APIService.shared.fetchPodcast(searchText: searchText) { (podcasts) in
        self.dataSource.podcasts = podcasts
        self.delegate.podcasts = podcasts
        self.tableView.reloadData()
      }
    })
  }
}
