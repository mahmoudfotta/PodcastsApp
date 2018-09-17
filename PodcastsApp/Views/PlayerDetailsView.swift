//
//  PlayerDetailsView.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 9/7/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import UIKit
import AVKit

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
            playEpisode()
            
            guard let url = URL(string: episode.imageUrl ?? "") else {return}
            episodeImageView.sd_setImage(with: url, completed: nil)
            miniEpisodeImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(1, 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = time.toDisplayString()
            
            let durationTime = self?.player.currentItem?.duration
            self?.durationLabel.text = durationTime?.toDisplayString()
            
            self?.updateCurrentTimeSlider()
            
        }
    }
    
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(1, 1))
        let percantage = currentTimeSeconds / durationSeconds
        currentTimeSlider.value = Float(percantage)
    }
    
    var panGesture: UIPanGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
        observePlayerCurrentTime()
        
        let time = CMTimeMake(1, 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeEpisodeImageView()
        }
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            handlePanChanged(gesture: gesture)
        } else if gesture.state == .ended {
            handlePanEnded(gesture: gesture)
        }
    }
    
    func handlePanChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        self.miniPlayerView.alpha = 1 + translation.y / 200
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = .identity
            
            if translation.y < -200 || velocity.y < -500 {
                let mainTabBar = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
                mainTabBar?.maximizeDetailsView(episode: nil)
                gesture.isEnabled = false
            } else {
                self.miniPlayerView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
        })
    }
    
    @objc func handleTapMaximize() {
        let mainTabBar = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBar?.maximizeDetailsView(episode: nil)
        panGesture.isEnabled = false
    }
    
    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }
    
    fileprivate func playEpisode() {
        guard let url = URL(string: episode.streamUrl) else {return}
        let playerItem = AVPlayerItem(url: url)
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
        } else {
            player.pause()
            playPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
        }
    }
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else {
            return
        }
        let durationInSEconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSEconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, 1)
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
        let fifteenSeconds = CMTimeMake(delta, 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    
    
    @IBAction func dismiss(_ sender: Any) {
        let mainTabBar = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBar?.minimizeDetailsView()
        panGesture.isEnabled = true
    }
}




