//
//  FavoritesFlowLayoutDelegate.swift
//  PodcastsApp
//
//  Created by Mahmoud Abolfotoh on 1/18/19.
//  Copyright © 2019 mahmoud gamal. All rights reserved.
//

import UIKit

class FavoritesFlowLayoutDelegate: NSObject, UICollectionViewDelegateFlowLayout {
  
  var cellTappedAction: ((IndexPath) -> Void)?
  
  init(cellTappedAction: @escaping (IndexPath) -> Void) {
    self.cellTappedAction = cellTappedAction
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let width = (collectionView.frame.width - 3 * 16)/2
    
    return CGSize(width: width, height: width+46)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 16
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    cellTappedAction?(indexPath)
  }
}
