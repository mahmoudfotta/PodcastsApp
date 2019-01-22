//
//  ApiService.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 9/4/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

class APIService {
  
  let baseitunesSearchUrl = "https://itunes.apple.com/search"
  typealias EpisodeDownloadCompleteTuple = (fileUrl: String, episodeTitle: String)
  static let shared = APIService()
  
  func downlodEpisode(episode: Episode) {
    let downloadRequest = DownloadRequest.suggestedDownloadDestination()
    Alamofire.download(episode.streamUrl, to: downloadRequest).downloadProgress { (progress) in      
      NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title, "progress": progress.fractionCompleted])
      }.response { (response) in
        print(response.destinationURL?.absoluteString ?? "")
        
        let episodeDownloadComplete = EpisodeDownloadCompleteTuple(response.destinationURL?.absoluteString ?? "", episode.title)
        NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete, userInfo: nil)
        
        var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
        guard let index = downloadedEpisodes.firstIndex(where: {
          $0.author == episode.author && $0.title == episode.title
        }) else {return}
        downloadedEpisodes[index].fileUrl = response.destinationURL?.absoluteString ?? ""
        
        do {
          let data = try JSONEncoder().encode(downloadedEpisodes)
          UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpidodesKey)
          
        } catch let err {
          print(err)
        }
    }
  }
  
  func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode])->()) {
    let secureFeedUrl = feedUrl.toSecureHTTPS()
    
    guard let url = URL(string: secureFeedUrl) else {return}
    
    DispatchQueue.global(qos: .background).async {
      let parser = FeedParser(URL: url)
      parser?.parseAsync(result: { (result) in
        
        if let err = result.error {
          print("failed to parse xml feed: ", err)
          return
        }
        
        guard let feed = result.rssFeed else {return}
        let episodes = feed.toEpisodes()
        completionHandler(episodes)
      })
    }
  }
  
  func fetchPodcast(searchText: String, completionHandler: @escaping ([Podcast])->()) {
    let parameters = ["term": searchText, "media": "podcast"]
    
    Alamofire.request(baseitunesSearchUrl, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
      if let err = dataResponse.error {
        print(err)
        return
      }
      guard let data = dataResponse.data else {return}
      do {
        let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
        print("search result", searchResult)
        completionHandler(searchResult.results)
      } catch let decodeErr {
        print("failed to decode: ", decodeErr)
      }
    }
  }
  
  struct SearchResult: Decodable {
    let resultCount: Int
    let results: [Podcast]
  }
}
