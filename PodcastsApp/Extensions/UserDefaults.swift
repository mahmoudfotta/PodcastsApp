//
//  UserDefaults.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 10/3/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import Foundation

extension UserDefaults {
  
  static let favoritedPodcastKey = "favoritedPodcastKey"
  static let downloadedEpidodesKey = "downloadedEpidodeKey"
  
  func deleteEpisode(episode: Episode) {
    let savedEpisodes = downloadedEpisodes()
    let filteredEpisodes = savedEpisodes.filter { (savedEpisode) -> Bool in
      return savedEpisode.title != episode.title && savedEpisode.author != episode.author
    }
    do {
      let data = try JSONEncoder().encode(filteredEpisodes)
      UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpidodesKey)
    } catch let encodeErr {
      print("Failed to encode episode:", encodeErr)
    }
  }
  
  func downloadEpisode(episode: Episode) {
    do {
      var episodes = downloadedEpisodes()
      
      episodes.insert(episode, at: 0)
      let data = try JSONEncoder().encode(episodes)
      UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpidodesKey)
      
    } catch let encodeErr {
      print("Failed to encode episode:", encodeErr)
    }
  }
  
  func downloadedEpisodes() -> [Episode] {
    guard let episodesData = data(forKey: UserDefaults.downloadedEpidodesKey) else {return []}
    do {
      let episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
      return episodes
    } catch let decodeError {
      print("error while decoding", decodeError)
    }
    return []
  }
  
  func savedPodcasts() -> [Podcast] {
    guard let savedPodcastData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else {return []}
    guard let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastData) as? [Podcast] else {return []}
    return savedPodcasts
  }
  
  func deletePodcast(podcast: Podcast) {
    let podcasts = savedPodcasts()
    let filteredPodcasts = podcasts.filter { (savedPodcast) -> Bool in
      return savedPodcast.trackName != podcast.trackName && savedPodcast.artistName != podcast.artistName
    }
    let data = NSKeyedArchiver.archivedData(withRootObject: filteredPodcasts)
    UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
  }
}
