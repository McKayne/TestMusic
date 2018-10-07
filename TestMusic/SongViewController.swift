//
//  SongViewController.swift
//  TestMusic
//
//  Created by Nikolay Taran on 06.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class SongViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var song: Song!
    
    private let background = UIImageView()
    private let activity = UIActivityIndicatorView()
    
    private let genre = UILabel()
    let infoTableView = UITableView()
    private let artwork = UIImageView()
    
    private let player = AVQueuePlayer()
    private let playerStatus = UILabel()
    private let playerButton = UIButton()
    private var nowPlaying = false
    private var preview: AVPlayerItem?
    private let playerActivity = UIActivityIndicatorView()
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            let text = "\(song.trackName ?? "") by \(song.artistName ?? "")"
            return CGFloat(song.numberOfLines(string: text, font: UIFont(name: "SFProDisplay-Ultralight", size: 20.0)!) + 2) * 25.0
        case 1:
            let text = "\(song.collectionName ?? ""), 2014"
            return CGFloat(song.numberOfLines(string: text, font: UIFont(name: "SFProDisplay-Ultralight", size: 20.0)!) + 2) * 25.0
        case 3:
            return 300
        default:
            return 50
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func playPreview(sender: UIButton) {
        if !nowPlaying {
            
            if preview == nil {
                playerButton.setTitle("", for: .normal)
                playerActivity.isHidden = false
                playerActivity.startAnimating()
                
                OperationQueue().addOperation {
                    self.preview = AVPlayerItem(url: self.song.previewURL)
                    
                    self.nowPlaying = true
                    
                    DispatchQueue.main.sync {
                        self.playerActivity.stopAnimating()
                        self.playerActivity.isHidden = true
                        
                        self.playerButton.setTitle("■", for: .normal)
                        
                        self.player.removeAllItems()
                        self.player.insert(self.preview!, after: nil)
                        self.player.play()
                    }
                    
                    
                }
            } else {
                nowPlaying = true
                
                playerButton.setTitle("■", for: .normal)
                
                player.removeAllItems()
                player.insert(preview!, after: nil)
                player.play()
            }
        } else {
            nowPlaying = false
            
            playerButton.setTitle("▶", for: .normal)
            
            preview!.seek(to: CMTimeMake(0, 1000), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            player.pause()
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        genre.text = song.genre
        
        let cell = UITableViewCell()
        
        cell.backgroundColor = .clear
        cell.textLabel?.font = UIFont(name: "SFProDisplay-Ultralight", size: 20.0)
        cell.textLabel?.textColor = .white
        
        cell.textLabel?.numberOfLines = 0
        
        switch indexPath.row {
        case 0:
            let text = "\(song.trackName ?? "") by \(song.artistName ?? "")"
            cell.textLabel?.text = text
            cell.textLabel?.sizeToFit()
        case 1:
            let index = song.releaseDate.index(song.releaseDate.startIndex, offsetBy: 4)
            cell.textLabel?.text = "\(song.collectionName ?? ""), \(song.releaseDate.substring(to: index))"
            cell.textLabel?.sizeToFit()
        case 2:
            
            playerActivity.color = .white
            
            playerStatus.textColor = .white
            playerStatus.text = "Play preview"
            cell.contentView.addSubview(playerStatus)
            
            playerButton.frame = CGRect(x: 10, y: 0, width: 50, height: 30)
            playerButton.setTitle("▶", for: .normal)
            
            playerButton.addSubview(playerActivity)
            ViewController.performAutolayoutConstants(subview: playerActivity, view: playerButton, left: 0, right: 0, top: 0, bottom: 0)
            
            playerButton.addTarget(self, action: #selector(playPreview(sender:)), for: .touchUpInside)
            cell.contentView.addSubview(playerButton)
            
            ViewController.performAutolayoutConstants(subview: playerButton, view: cell.contentView, left: 10, right: -280, top: 0, bottom: 0)
            ViewController.performAutolayoutConstants(subview: playerStatus, view: cell.contentView, left: 60, right: 0, top: 0, bottom: 0)
        case 3:
            activity.isHidden = false
            activity.color = .white
            activity.startAnimating()
            
            cell.contentView.addSubview(activity)
            ViewController.performAutolayoutConstants(subview: activity, view: cell.contentView, left: 320.0 / 2 - 15, right: -320.0 / 2 + 15, top: 300.0 / 2 - 15, bottom: -300.0 / 2 + 15)
            
            
            cell.contentView.addSubview(artwork)
            ViewController.performAutolayoutConstants(subview: artwork, view: cell.contentView, left: 10.0, right: -10.0, top: 0.0, bottom: 0.0)
            
            OperationQueue().addOperation {
                self.artwork.image = UIImage(data: try! Data(contentsOf: self.song.artworkURL))
                
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                    self.activity.isHidden = true
                }
            }
        case 4:
            let minutes = UInt(song.trackTimeMillis)! / 1000 / 60
            let seconds = UInt(song.trackTimeMillis)! / 1000 - minutes * 60
            cell.textLabel?.text = "\(minutes) minutes \(seconds) seconds"
            cell.textLabel?.sizeToFit()
        case 5:
            cell.textLabel?.text = "Track \(song.trackNumber ?? "") of \(song.trackCount ?? "")"
            cell.textLabel?.sizeToFit()
        case 6:
            cell.textLabel?.text = "Disc \(song.discNumber ?? "") of \(song.discCount ?? "")"
            cell.textLabel?.sizeToFit()
        case 7:
            cell.textLabel?.text = "Price USD \(song.trackPrice ?? "")"
            cell.textLabel?.sizeToFit()
        case 8:
            cell.textLabel?.text = "Collection USD \(song.collectionPrice ?? "")"
            cell.textLabel?.sizeToFit()
        default:
            cell.textLabel?.text = "Dummy"
        }
        
        
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        background.frame = CGRect(x: 0, y: 0, width: 320, height: 568)
        background.image = UIImage(named: "background.png")
        view.addSubview(background)
        
        genre.font = UIFont(name: "SFProDisplay-Ultralight", size: 12.0)
        genre.textColor = .white
        view.addSubview(genre)
        ViewController.performAutolayoutConstants(subview: genre, view: view, left: 27.0, right: 0.0, top: 30, bottom: -470)
        
        infoTableView.backgroundColor = .clear
        infoTableView.allowsSelection = false
        infoTableView.separatorStyle = .none
        infoTableView.tableFooterView = UIView(frame: .zero)
        infoTableView.delegate = self
        infoTableView.dataSource = self
        view.addSubview(infoTableView)
        ViewController.performAutolayoutConstants(subview: infoTableView, view: view, left: 0.0, right: 0.0, top: 70, bottom: 0)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        infoTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        artwork.image = nil
        artwork.removeFromSuperview()
        
        preview = nil
    }
}
