//
//  FavoritePodcastCell.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 10/1/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import UIKit

class FavoritePodcastCell: UICollectionViewCell {
    
    let imageView = UIImageView(image: #imageLiteral(resourceName: "appicon"))
    let nameLabel = UILabel()
    let artistNameLabel = UILabel()
    
    var podcast: Podcast! {
        didSet {
            nameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            
            let url = URL(string: podcast.artworkUrl600 ?? "")
            imageView.sd_setImage(with: url)
        }
    }
    
    fileprivate func stylizeUi() {
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.text = "Podcast Name"
        artistNameLabel.text = "Artist Name"
        artistNameLabel.font = UIFont.systemFont(ofSize: 14)
        artistNameLabel.textColor = .lightGray
    }
    
    fileprivate func setupViewa() {
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel, artistNameLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        stylizeUi()
        setupViewa()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
