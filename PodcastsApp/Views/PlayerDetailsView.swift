//
//  PlayerDetailsView.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 9/7/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import UIKit

class PlayerDetailsView: UIView {

    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var playPauseBtn: UIButton!
    
    
    var episode: Episode! {
        didSet {
            guard let url = URL(string: episode.imageUrl ?? "") else {return}
            episodeImageView.sd_setImage(with: url, completed: nil)
            titleLabel.text = episode.title
            authorLabel.text = episode.author
        }
    }

    @IBAction func dismiss(_ sender: Any) {
        removeFromSuperview()
    }
}
