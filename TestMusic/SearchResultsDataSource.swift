//
//  SearchResultsDataSource.swift
//  TestMusic
//
//  Created by Nikolay Taran on 05.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import Foundation
import UIKit

class SearchResultsDataSource: NSObject, UITableViewDataSource {
    
    var filteredSongs: [Song] = []
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        
        cell.textLabel?.font = UIFont(name: "SFProDisplay-Ultralight", size: 20.0)
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = String(indexPath.row + 1)
        
        let artistLabel = UILabel()
        artistLabel.font = UIFont(name: "SFProDisplay-Ultralight", size: 12.0)
        artistLabel.textColor = .white
        artistLabel.text = filteredSongs[indexPath.row].artistName
        
        let songLabel = UILabel()
        songLabel.font = UIFont(name: "SFProDisplay-Ultralight", size: 12.0)
        songLabel.textColor = .white
        songLabel.text = "\(filteredSongs[indexPath.row].trackName ?? ""), \(filteredSongs[indexPath.row].collectionName ?? "")"
        
        cell.contentView.addSubview(artistLabel)
        ViewController.performAutolayoutConstants(subview: artistLabel, view: cell.contentView, left: 50.0, right: 0.0, top: 0, bottom: -25)
        
        cell.contentView.addSubview(songLabel)
        ViewController.performAutolayoutConstants(subview: songLabel, view: cell.contentView, left: 50.0, right: 0.0, top: 25, bottom: 0)
        
        return cell
    }
}
