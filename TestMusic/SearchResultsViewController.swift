//
//  SearchResultsViewController.swift
//  TestMusic
//
//  Created by Nikolay Taran on 05.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    private let background = UIImageView()
    private let activity = UIActivityIndicatorView()
    
    private let songsFound = UILabel()
    
    let notFound1 = UILabel(), notFound2 = UILabel()
    
    private let filterBar = UITextField()
    private var isTextChanged = false
    private let arrowButton = UIButton()
    
    private let resultsTableView = UITableView()
    private let searchResultsDataSource = SearchResultsDataSource()
    private var songs: [Song] = []
    
    private let songViewController = SongViewController()
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: resultsTableView))! {
            return false
        }
        return true
    }
    
    func dismissKeyboardOnTap() {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !isTextChanged {
            isTextChanged = true
            filterBar.textAlignment = .center
            filterBar.text = ""
            filterBar.textColor = .white
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if filterBar.text?.characters.count == 0 {
            isTextChanged = false
            filterBar.textColor = .gray
            filterBar.textAlignment = .left
            filterBar.text = "\tFilter"
        }
    }
    
    func textFieldDidChange() {
        if filterBar.text!.characters.count > 0 {
            arrowButton.isHidden = false
        } else {
            arrowButton.isHidden = true
        }
        
        filterSongs(filter: filterBar.text!)
        songsFound.text = "\(searchResultsDataSource.filteredSongs.count) songs"
        resultsTableView.reloadData()
    }
    
    func dismissKeyboardAndFilter(sender: UIButton) {
        view.endEditing(true)
        filterSongs(filter: filterBar.text!)
        songsFound.text = "\(searchResultsDataSource.filteredSongs.count) songs"
        resultsTableView.reloadData()
    }
    
    private func filterSongs(filter: String) {
        if filter.characters.count > 0 {
            searchResultsDataSource.filteredSongs = []
            
            for song in songs {
                var isFiltered = false
                
                if (song.artistName.lowercased().range(of: filter.lowercased()) != nil) {
                    isFiltered = true
                }
                if (song.collectionName.lowercased().range(of: filter.lowercased()) != nil) {
                    isFiltered = true
                }
                if (song.trackName.lowercased().range(of: filter.lowercased()) != nil) {
                    isFiltered = true
                }
                
                if isFiltered {
                    searchResultsDataSource.filteredSongs.append(song)
                }
            }
        } else {
            searchResultsDataSource.filteredSongs = songs
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(searchResultsDataSource.filteredSongs[indexPath.row].lineCount + 1) * 15.0
    }
    
    func stripString(string: String, limit: Int) -> String {
        var chars = Array(string.characters)
        if chars.count > limit {
            var stripped: [Character] = []
            for i in 0..<limit {
                stripped.append(chars[i])
            }
            for _ in 0..<3 {
                stripped.append(".")
            }
            return String(stripped)
        } else {
            return string
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let backItem = UIBarButtonItem()
        backItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "SFProDisplay-Ultralight", size: 20.0)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
        
        let title: String! = searchResultsDataSource.filteredSongs[indexPath.row].trackName!
        backItem.title = stripString(string: title, limit: 13)
        
        navigationController!.navigationBar.topItem!.backBarButtonItem = backItem
        
        songViewController.song = searchResultsDataSource.filteredSongs[indexPath.row]
        songViewController.infoTableView.reloadData()
        navigationController?.pushViewController(songViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func parseJSON() {
        do {
            let text = try String(contentsOf: Bundle.main.url(forResource: "1", withExtension: "txt")!, encoding: .utf8)
            
            let parseData = try JSONSerialization.jsonObject(with: text.data(using: .utf8)!) as! [String: Any]
            
            if let nested = parseData["results"] as? [[String: Any]] {
                for result in nested {
                    if String(describing: result["kind"]!) == "song" {
                        let song = Song()
                        
                        song.artistName = String(describing: result["artistName"]!)
                        song.collectionName = String(describing: result["collectionName"]!)
                        song.trackName = String(describing: result["trackName"]!)
                        song.artworkURL = URL(string: String(describing: result["artworkUrl100"]!))
                        song.genre = String(describing: result["primaryGenreName"]!)
                        
                        song.releaseDate = String(describing: result["releaseDate"]!)
                        
                        song.discNumber = String(describing: result["discNumber"]!)
                        song.discCount = String(describing: result["discCount"]!)
                        song.trackNumber = String(describing: result["trackNumber"]!)
                        song.trackCount = String(describing: result["trackCount"]!)
                        
                        song.trackPrice = String(describing: result["trackPrice"]!)
                        song.collectionPrice = String(describing: result["collectionPrice"]!)
                        
                        song.previewURL = URL(string: String(describing: result["previewUrl"]!))
                        
                        song.trackTimeMillis = String(describing: result["trackTimeMillis"]!)
                        
                        song.info = "\(song.trackName ?? "")\n\(song.artistName ?? ""), \(song.collectionName ?? "")"
                        song.cellFont = UIFont(name: "SFProDisplay-Ultralight", size: 12.0)
                        
                        song.lineCount = song.numberOfLines(string: song.info)
                        
                        songs.append(song)
                    }
                }
            }
        } catch {
            print("JSON deserialization error")
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardOnTap))
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        
        background.frame = CGRect(x: 0, y: 0, width: 320, height: 568)
        background.image = UIImage(named: "background.png")
        view.addSubview(background)
        
        activity.isHidden = false
        activity.color = .white
        activity.startAnimating()
        
        view.addSubview(activity)
        ViewController.performAutolayoutConstants(subview: activity, view: view, left: 320.0 / 2 - 15, right: -320.0 / 2 + 15, top: 568.0 / 2 - 15, bottom: -568.0 / 2 + 15)
        
        songsFound.font = UIFont(name: "SFProDisplay-Ultralight", size: 12.0)
        songsFound.textColor = .white
        
        notFound1.textAlignment = .center
        notFound1.textColor = .white
        notFound1.font = UIFont(name: "SFProDisplay-Ultralight", size: 34.0)
        notFound1.text = "NOTHING FOUND"
        
        notFound2.textAlignment = .center
        notFound2.textColor = .white
        notFound2.font = UIFont(name: "SFProDisplay-Ultralight", size: 12.0)
        notFound2.text = "Please change search or filter text and try again"
        
        filterBar.backgroundColor = .clear
        filterBar.delegate = self
        filterBar.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        
        filterBar.layer.cornerRadius = 20.0
        filterBar.layer.borderWidth = 2.0
        filterBar.layer.borderColor = UIColor.white.cgColor
        
        filterBar.font = UIFont(name: "SFProDisplay-Ultralight", size: 12.0)
        filterBar.textColor = .gray
        filterBar.text = "\tFilter"
        
        arrowButton.backgroundColor = .clear
        arrowButton.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        arrowButton.addTarget(self, action: #selector(dismissKeyboardAndFilter(sender:)), for: .touchUpInside)
        arrowButton.setTitle("→", for: .normal)
        filterBar.rightView = arrowButton
        filterBar.rightViewMode = .always
        arrowButton.isHidden = true
        
        searchResultsDataSource.searchResultsViewController = self
        resultsTableView.backgroundColor = .clear
        resultsTableView.separatorColor = UIColor(red: 12.0 / 255.0, green: 21.0 / 255.0, blue: 49.0 / 255.0, alpha: 1.0)
        resultsTableView.delegate = self
        resultsTableView.tableFooterView = UIView(frame: .zero)
        
        view.addSubview(songsFound)
        ViewController.performAutolayoutConstants(subview: songsFound, view: view, left: 27.0, right: 0.0, top: 30, bottom: -470)
        
        view.addSubview(notFound1)
        ViewController.performAutolayoutConstants(subview: notFound1, view: view, left: 0.0, right: 0.0, top: 568.0 / 4 - 10, bottom: -568.0 / 2 - 10)
        
        view.addSubview(notFound2)
        ViewController.performAutolayoutConstants(subview: notFound2, view: view, left: 0.0, right: 0.0, top: 568.0 / 4 + 20, bottom: -568.0 / 2 + 20)
        
        view.addSubview(filterBar)
        ViewController.performAutolayoutConstants(subview: filterBar, view: view, left: 20.0, right: -20.0, top: 100, bottom: -430)
        
        view.addSubview(resultsTableView)
        ViewController.performAutolayoutConstants(subview: resultsTableView, view: view, left: 0.0, right: 0.0, top: 150, bottom: 0.0)
        
        songsFound.isHidden = true
        notFound1.isHidden = true
        notFound2.isHidden = true
        filterBar.isHidden = true
        resultsTableView.isHidden = true
        
        OperationQueue().addOperation {
            self.parseJSON()
            
            DispatchQueue.main.async {
                self.songsFound.text = "\(self.songs.count) songs"
                self.searchResultsDataSource.filteredSongs = self.songs
                self.resultsTableView.dataSource = self.searchResultsDataSource
                
                self.activity.stopAnimating()
                self.activity.isHidden = true
                
                self.songsFound.isHidden = false
                
                self.filterBar.isHidden = false
                self.resultsTableView.isHidden = false
                
                self.resultsTableView.reloadData()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.isNavigationBarHidden = false
        
        
    }
}
