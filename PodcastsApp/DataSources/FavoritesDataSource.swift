//
//  FavoritesDataSource.swift
//  PodcastsApp
//
//  Created by Mahmoud Abolfotoh on 1/18/19.
//  Copyright © 2019 mahmoud gamal. All rights reserved.
//

import UIKit

class FavoritesDataSource: NSObject, UICollectionViewDataSource {
  var podcasts = UserDefaults.standard.savedPodcasts()
  fileprivate let cellId = "cellId"
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return podcasts.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // swiftlint:disable:next force_cast
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FavoritePodcastCell
    cell.podcast = podcasts[indexPath.item]
    return cell
  }
  
  func podcast(at index: Int) -> Podcast {
    return podcasts[index]
  }
  
  func removePodcast(at index: Int) {
    podcasts.remove(at: index)
  }
  
  func refreshFavoritesPodcasts() {
    podcasts = UserDefaults.standard.savedPodcasts()
  }
}
