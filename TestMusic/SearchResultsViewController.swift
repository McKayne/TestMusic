//
//  SearchResultsViewController.swift
//  TestMusic
//
//  Created by для интернета on 05.10.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate {
    
    private let background = UIImageView()
    private let songsFound = UILabel()
    
    private let filterBar = UITextField()
    private var isTextChanged = false
    
    private let resultsTableView = UITableView()
    private let searchResultsDataSource = SearchResultsDataSource()
    private var songs: [Song] = []
    
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
        return 50.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardOnTap)))
        
        background.frame = CGRect(x: 0, y: 0, width: 320, height: 568)
        background.image = UIImage(named: "background.png")
        view.addSubview(background)
        
        songsFound.font = UIFont(name: "SFProDisplay-Ultralight", size: 12.0)
        songsFound.textColor = .white
        
        filterBar.backgroundColor = .clear
        filterBar.delegate = self
        filterBar.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        
        filterBar.layer.cornerRadius = 20.0
        filterBar.layer.borderWidth = 2.0
        filterBar.layer.borderColor = UIColor.white.cgColor
        
        filterBar.font = UIFont(name: "SFProDisplay-Ultralight", size: 12.0)
        filterBar.textColor = .gray
        filterBar.text = "\tFilter"
        
        resultsTableView.backgroundColor = .clear
        resultsTableView.delegate = self
        resultsTableView.tableFooterView = UIView(frame: .zero)
        
        view.addSubview(songsFound)
        ViewController.performAutolayoutConstants(subview: songsFound, view: view, left: 27.0, right: 0.0, top: 30, bottom: -470)
        
        view.addSubview(filterBar)
        ViewController.performAutolayoutConstants(subview: filterBar, view: view, left: 20.0, right: -20.0, top: 100, bottom: -430)
        
        view.addSubview(resultsTableView)
        ViewController.performAutolayoutConstants(subview: resultsTableView, view: view, left: 0.0, right: 0.0, top: 150, bottom: 0.0)
        
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
                        
                        songs.append(song)
                    }
                }
            }
            
            print(songs.count)
            
            songsFound.text = "\(songs.count) songs"
            searchResultsDataSource.filteredSongs = songs
            resultsTableView.dataSource = searchResultsDataSource
        } catch {
            print("JSON deserialization error")
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
