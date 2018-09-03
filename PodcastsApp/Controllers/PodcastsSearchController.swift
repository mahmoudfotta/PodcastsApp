//
//  PodcastsSearchController.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 9/2/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import UIKit

class PodcastsSearchController: UITableViewController, UISearchBarDelegate {
    
    let cellId = "cellId"
    
    let podcasts = [
        Podcast(name: "podcast 1", artistName: "artist 1"),
        Podcast(name: "podcast 2", artistName: "artist 2"),
        Podcast(name: "podcast 3", artistName: "artist 3")
    ]
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
    }
    
    //MARK:- setup work
    
    fileprivate func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    
    fileprivate func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    //MARK:- tableview
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let podcast = podcasts[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(podcast.name)\n\(podcast.artistName)"
        cell.imageView?.image = #imageLiteral(resourceName: "appicon")
        return cell
    }
}
