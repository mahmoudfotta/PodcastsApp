//
//  IndicatorViewController.swift
//  PodcastsApp
//
//  Created by Mahmoud Abolfotoh on 1/22/19.
//  Copyright © 2019 mahmoud gamal. All rights reserved.
//

import UIKit

class IndicatorViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let indicatorview = UIActivityIndicatorView(style: .whiteLarge)
    indicatorview.color = .black
    indicatorview.startAnimating()
    indicatorview.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(indicatorview)
    
    indicatorview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    indicatorview.topAnchor.constraint(equalTo: view.topAnchor, constant: 90).isActive = true
  }
}
