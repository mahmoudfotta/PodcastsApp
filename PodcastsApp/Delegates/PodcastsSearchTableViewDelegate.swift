//
//  PodcastsSearchTableViewDelegate.swift
//  PodcastsApp
//
//  Created by Mahmoud Abolfotoh on 1/20/19.
//  Copyright © 2019 mahmoud gamal. All rights reserved.
//

import UIKit

class PodcastsSearchTableViewDelegate: NSObject, UITableViewDelegate {
  var podcastsSearchView = Bundle.main.loadNibNamed("PodcastsSearchingView", owner: self, options: nil)?.first as! UIView
  let searchController: UISearchController!
  var podcasts: [Podcast]?
  var cellTapped: ((IndexPath) -> Void)?
  
  init(searchController: UISearchController, cellTapped: @escaping ((IndexPath) -> Void)) {
    self.searchController = searchController
    self.cellTapped = cellTapped
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return podcastsSearchView
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    cellTapped?(indexPath)
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let label = UILabel()
    label.text = "please, enter a search term"
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    return label
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return podcasts?.isEmpty ?? true && searchController.searchBar.text?.isEmpty == true ? 250 : 0
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return podcasts?.isEmpty ?? true == true && searchController.searchBar.text?.isEmpty == false ? 200 : 0
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 132
  }
}
