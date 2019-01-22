//
//  UIViewController+AddChild.swift
//  PodcastsApp
//
//  Created by Mahmoud Abolfotoh on 1/22/19.
//  Copyright © 2019 mahmoud gamal. All rights reserved.
//

import UIKit

extension UIViewController {
  func add(_ child: UIViewController, frame: CGRect? = nil) {
    addChild(child)
    
    if let frame = frame {
      child.view.frame = frame
    }
    
    view.addSubview(child.view)
    child.didMove(toParent: self)
  }
  
  func remove() {
    willMove(toParent: nil)
    view.removeFromSuperview()
    removeFromParent()
  }
}
