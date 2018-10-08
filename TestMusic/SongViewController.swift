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

// ViewController для отображения информации о песне
class SongViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var song: Song!
    
    // Фоновое изображение
    private let background = UIImageView()
    
    // Индикатор загрузки
    private let activity = UIActivityIndicatorView()
    
    // Строка жанра
    private let genre = UILabel()
    
    // UITableView для вывода информации
    let infoTableView = UITableView()
    
    // Артворк
    private let artwork = UIImageView()
    
    // Плеер для воспроизведения образцов
    private let player = AVQueuePlayer()
    private let playerStatus = UILabel()
    private let playerButton = UIButton()
    private var nowPlaying = false
    private var preview: AVPlayerItem?
    private let playerActivity = UIActivityIndicatorView()
    
    // Метод делегата UTableView, возвращает высоту каждой конкретной ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            let text = "\(song.trackName ?? "") by \(song.artistName ?? "")"
            return CGFloat(song.numberOfLines(viewWidth: Double(view.frame.width), string: text, font: UIFont(name: "HelveticaNeue-Thin", size: 20.0)!) + 2) * 25.0 // возвращает высоту ячейки по формуле (число строк в строке(название + исполнитель) + 2) * 25
        case 1:
            let text = "\(song.collectionName ?? ""), 2014" // т.к. год всегда состоит из 4 символов, конкретный год здесь не имеет значения
            return CGFloat(song.numberOfLines(viewWidth: Double(view.frame.width), string: text, font: UIFont(name: "HelveticaNeue-Thin", size: 20.0)!) + 2) * 25.0 // возвращает высоту ячейки по формуле (число строк в строке(альбом + год) + 2) * 25
        case 3:
            return 300 // высота ячейки артворка
        default:
            return 50 // высота остальных ячеек
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    // Метод воспроизведения/остановки образца для прослушивания
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
    
    // Метод DataSource для заполнения UITableView с инфо
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        genre.text = song.genre
        
        let cell = UITableViewCell()
        
        cell.backgroundColor = .clear
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 20.0)
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
            
            let diff = (view.frame.width - 320.0) / 2.0 * 0.15
            ViewController.performAutolayoutConstants(subview: playerButton, view: cell.contentView, left: 10 + diff, right: -view.frame.width + 40 + diff, top: 0, bottom: 0)
            ViewController.performAutolayoutConstants(subview: playerStatus, view: cell.contentView, left: 60 + diff, right: 0, top: 0, bottom: 0)
        case 3:
            activity.isHidden = false
            activity.color = .white
            activity.startAnimating()
            
            cell.contentView.addSubview(activity)
            ViewController.performAutolayoutConstants(subview: activity, view: cell.contentView, left: view.frame.width / 2 - 15, right: -view.frame.width / 2 + 15, top: 300.0 / 2 - 15, bottom: -300.0 / 2 + 15)
            
            
            cell.contentView.addSubview(artwork)
            ViewController.performAutolayoutConstants(subview: artwork, view: cell.contentView, left: 10.0, right: -10.0, top: 0.0, bottom: 0.0)
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            // Загрузка обложки для отображения длительный процесс, поэтому выполняем его асинхронно
            // Все операции с изменеием свойств UIView необходимо выполнять в главном потоке
            DispatchQueue.main.async {
                self.artwork.image = UIImage(data: try! Data(contentsOf: self.song.artworkURL))
                self.artwork.setNeedsDisplay()
                self.activity.stopAnimating()
                self.activity.isHidden = true
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
        
        // Фоновое изображение
        background.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        background.image = UIImage(named: "background.png")
        view.addSubview(background)
        
        // Устанавливаем шрифт для строки о жанре
        genre.font = UIFont(name: "HelveticaNeue-Thin", size: 12.0)
        genre.textColor = .white
        view.addSubview(genre)
        ViewController.performAutolayoutConstants(subview: genre, view: view, left: 27.0, right: 0.0, top: 60, bottom: -view.frame.height + 90)
        
        infoTableView.backgroundColor = .clear
        infoTableView.allowsSelection = false
        infoTableView.separatorStyle = .none
        infoTableView.tableFooterView = UIView(frame: .zero)
        infoTableView.delegate = self
        infoTableView.dataSource = self
        view.addSubview(infoTableView)
        ViewController.performAutolayoutConstants(subview: infoTableView, view: view, left: 0.0, right: 0.0, top: 90, bottom: 0)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Возврат UITableView с информацией в начало
        infoTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        
        // Удаляем прошлый артворк
        artwork.image = nil
        artwork.removeFromSuperview()
        
        // Удаляем прошлый образец для прослушивания
        preview = nil
    }
}
