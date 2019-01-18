//
//  FavoritesController.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 10/1/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import UIKit

class FavoritesController: UICollectionViewController {
  
  fileprivate let cellId = "cellId"
  var dataSource = FavoritesDataSource()
  var flowDelegate: FavoritesFlowLayoutDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    dataSource.refreshFavoritesPodcasts()
    collectionView?.reloadData()
    UIApplication.mainTabBarController()?.viewControllers?[0].tabBarItem.badgeValue = nil
  }
  
  fileprivate func setupCollectionView() {
    collectionView?.backgroundColor = .white
    collectionView?.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: cellId)
    collectionView.dataSource = dataSource
    flowDelegate = FavoritesFlowLayoutDelegate(cellTappedAction: { [weak self] (indexPath) in
      self?.cellTapped(indexPath: indexPath)
    })
    collectionView.delegate = flowDelegate
    let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
    collectionView?.addGestureRecognizer(gesture)
  }
  
  @objc func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
    let location = gesture.location(in: collectionView)
    guard let selectedIndexPath = collectionView?.indexPathForItem(at: location) else {return}
    let selectedPodcast = dataSource.podcast(at: selectedIndexPath.item)
    alertToRemove(selectedPodcast, at: selectedIndexPath)
  }
  
  func cellTapped(indexPath: IndexPath) {
    let episodesController = EpisodesController()
    episodesController.podcast = dataSource.podcast(at: indexPath.item)
    navigationController?.pushViewController(episodesController, animated: true)
  }
  
  func alertToRemove(_ podcast: Podcast, at indexPath: IndexPath) {
    let alertController = UIAlertController(title: "Remove Podcast?", message: nil, preferredStyle: .actionSheet)
    alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
      self.dataSource.removePodcast(at: indexPath.item)
      self.collectionView?.deleteItems(at: [indexPath])
      UserDefaults.standard.deletePodcast(podcast: podcast)
    }))
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    present(alertController, animated: true)
  }
}
