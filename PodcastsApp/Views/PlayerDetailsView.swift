//
//  PlayerDetailsView.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 9/7/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerDetailsView: UIView {
  
  @IBOutlet weak var currentTimeSlider: UISlider!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var currentTimeLabel: UILabel!
  @IBOutlet weak var episodeImageView: UIImageView! {
    didSet {
      episodeImageView.layer.cornerRadius = 5
      episodeImageView.clipsToBounds = true
      self.episodeImageView.transform = shrunkenTransform
    }
  }
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var authorLabel: UILabel!
  @IBOutlet weak var playPauseBtn: UIButton! {
    didSet {
      playPauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
      playPauseBtn.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
    }
  }
  
  @IBOutlet weak var miniPlayerView: UIView!
  @IBOutlet weak var maximizedStackView: UIStackView!
  
  @IBOutlet weak var miniTitleLabel: UILabel!
  @IBOutlet weak var miniEpisodeImageView: UIImageView!
  @IBOutlet weak var miniFastForwardBtn: UIButton! {
    didSet {
      miniFastForwardBtn.imageView?.contentMode = .scaleAspectFit
    }
  }
  @IBOutlet weak var miniPlayPauseBtn: UIButton! {
    didSet {
      miniPlayPauseBtn.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
      miniPlayPauseBtn.imageView?.contentMode = .scaleAspectFit
    }
  }
  
  var episode: Episode! {
    didSet {
      titleLabel.text = episode.title
      authorLabel.text = episode.author
      miniTitleLabel.text = episode.title
      setupAudioSession()
      playEpisode()
      setupNowPlayingInfo()
      guard let url = URL(string: episode.imageUrl ?? "") else {return}
      episodeImageView.sd_setImage(with: url, completed: nil)
      miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
        let image = self.episodeImageView.image ?? UIImage()
        let artWork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> UIImage in
          return image
        })
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artWork
      }
    }
  }
  
  let player: AVPlayer = {
    let avPlayer = AVPlayer()
    avPlayer.automaticallyWaitsToMinimizeStalling = false
    return avPlayer
  }()
  
  fileprivate func observePlayerCurrentTime() {
    let interval = CMTimeMake(value: 1, timescale: 2)
    player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
      self?.currentTimeLabel.text = time.toDisplayString()
      let durationTime = self?.player.currentItem?.duration
      self?.durationLabel.text = durationTime?.toDisplayString()
      self?.updateCurrentTimeSlider()
      
    }
  }
  
  fileprivate func updateCurrentTimeSlider() {
    let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
    let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
    let percantage = currentTimeSeconds / durationSeconds
    currentTimeSlider.value = Float(percantage)
  }
  
  var panGesture: UIPanGestureRecognizer!
  
  fileprivate func setupGestures() {
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
    panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    miniPlayerView.addGestureRecognizer(panGesture)
    maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDissmisalPan)))
  }
  
  @objc func handleDissmisalPan(gesture: UIPanGestureRecognizer) {
    if gesture.state == .changed {
      let translation = gesture.translation(in: superview)
      maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
    } else if gesture.state == .ended {
      let translation = gesture.translation(in: superview)
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        self.maximizedStackView.transform = .identity
        if translation.y > 100 {
          let mainTabBar = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
          mainTabBar?.minimizeDetailsView()
        }
      })
    }
  }
  
  fileprivate func setupAudioSession() {
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)), mode: .spokenAudio)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch let sessionErr {
      print("Session error \(sessionErr)")
    }
  }
  
  fileprivate func setupRemoteControl() {
    UIApplication.shared.beginReceivingRemoteControlEvents()
    
    let commandCenter = MPRemoteCommandCenter.shared()
    
    commandCenter.playCommand.isEnabled = true
    commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
      self.player.play()
      self.playPauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
      self.miniPlayPauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
      self.setupElapsedTime(playBackRate: 1)
      return .success
    }
    
    commandCenter.pauseCommand.isEnabled = true
    commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
      self.player.pause()
      self.playPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
      self.miniPlayPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
      self.setupElapsedTime(playBackRate: 0)
      return .success
    }
    
    commandCenter.togglePlayPauseCommand.isEnabled = true
    commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
      self.handlePlayPause()
      return .success
    }
    
    commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
    commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePrevTrack))
    
  }
  
  var playListEpisodes = [Episode]()
  
  @objc fileprivate func handlePrevTrack() {
    if playListEpisodes.count == 0 {return}
    let currentEpisodeIndex = playListEpisodes.index { (ep) -> Bool in
      return self.episode.title == ep.title && self.episode.author == ep.author
    }
    
    guard let index = currentEpisodeIndex else {return}
    
    let prevEpisode: Episode
    
    if index == 0 {
      prevEpisode = playListEpisodes[playListEpisodes.count - 1]
    } else {
      prevEpisode = playListEpisodes[index - 1]
    }
    
    self.episode = prevEpisode
  }
  
  @objc fileprivate func handleNextTrack() {
    if playListEpisodes.count == 0 {return}
    let currentEpisodeIndex = playListEpisodes.index { (ep) -> Bool in
      return self.episode.title == ep.title && self.episode.author == ep.author
    }
    
    guard let index = currentEpisodeIndex else {return}
    
    let nextEpisode: Episode
    
    if index == playListEpisodes.count - 1 {
      nextEpisode = playListEpisodes[0]
    } else {
      nextEpisode = playListEpisodes[index + 1]
    }
    
    self.episode = nextEpisode
  }
  
  fileprivate func setupElapsedTime(playBackRate: Float) {
    let elapsedTime = CMTimeGetSeconds(player.currentTime())
    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playBackRate
  }
  
  fileprivate func observeBoundrayTime() {
    let time = CMTimeMake(value: 1, timescale: 3)
    let times = [NSValue(time: time)]
    player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
      self?.enlargeEpisodeImageView()
      self?.setupLockScreenDuration()
    }
  }
  
  fileprivate func setupLockScreenDuration() {
    guard let currentItem = player.currentItem else {return}
    let durationInSeconds = CMTimeGetSeconds(currentItem.duration)
    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
  }
  
  fileprivate func setupInterruptionObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
  }
  
  @objc func handleInterruption(notification: Notification) {
    guard let userInfo = notification.userInfo else {return}
    guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else {return}
    if type == AVAudioSession.InterruptionType.began.rawValue {
      playPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
      miniPlayPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    } else {
      
      guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {return}
      if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
        player.play()
        playPauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayPauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    setupRemoteControl()
    setupGestures()
    setupInterruptionObserver()
    observePlayerCurrentTime()
    observeBoundrayTime()
  }
  
  fileprivate func setupNowPlayingInfo() {
    var nowPlayingInfo = [String: Any]()
    nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
    nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
  }
  
  static func initFromNib() -> PlayerDetailsView {
    return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
  }
  
  fileprivate func playEpisode() {
    if episode.fileUrl != nil {
      playEpisodeUsingFileUrl()
    } else {
      guard let url = URL(string: episode.streamUrl) else {return}
      let playerItem = AVPlayerItem(url: url)
      player.replaceCurrentItem(with: playerItem)
      player.play()
    }
  }
  
  fileprivate func playEpisodeUsingFileUrl() {
    guard let fileUrl = URL(string: episode.fileUrl ?? "") else {return}
    let fileName = fileUrl.lastPathComponent
    guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
    
    trueLocation.appendPathComponent(fileName)
    
    let playerItem = AVPlayerItem(url: trueLocation)
    player.replaceCurrentItem(with: playerItem)
    player.play()
  }
  
  fileprivate func enlargeEpisodeImageView() {
    UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.episodeImageView.transform = .identity
    }, completion: nil)
  }
  
  fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
  fileprivate func shrinkEpisodeImageView() {
    UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.episodeImageView.transform = self.shrunkenTransform
    }, completion: nil)
  }
  
  @objc func handlePlayPause() {
    if player.timeControlStatus == .paused {
      player.play()
      playPauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
      miniPlayPauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
      enlargeEpisodeImageView()
      self.setupElapsedTime(playBackRate: 1)
    } else {
      player.pause()
      playPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
      miniPlayPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
      shrinkEpisodeImageView()
      self.setupElapsedTime(playBackRate: 0)
    }
  }
  
  @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
    let percentage = currentTimeSlider.value
    guard let duration = player.currentItem?.duration else {
      return
    }
    let durationInSEconds = CMTimeGetSeconds(duration)
    let seekTimeInSeconds = Float64(percentage) * durationInSEconds
    let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
    player.seek(to: seekTime)
  }
  
  @IBAction func handleRewined(_ sender: Any) {
    seekToCurrentTime(delta: -15)
  }
  
  
  @IBAction func handleFastForward(_ sender: Any) {
    seekToCurrentTime(delta: 15)
  }
  
  @IBAction func handleMiniFastForward(_ sender: Any) {
    seekToCurrentTime(delta: 15)
  }
  @IBAction func handleVolumeChange(_ sender: UISlider) {
    player.volume = sender.value
  }
  
  fileprivate func seekToCurrentTime(delta: Int64) {
    let fifteenSeconds = CMTimeMake(value: delta, timescale: 1)
    let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
    player.seek(to: seekTime)
  }
  
  
  @IBAction func dismiss(_ sender: Any) {
    let mainTabBar = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
    mainTabBar?.minimizeDetailsView()
  }
}





// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
  return input.rawValue
}
