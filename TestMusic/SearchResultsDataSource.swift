//
//  SearchResultsDataSource.swift
//  TestMusic
//
//  Created by Nikolay Taran on 05.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import Foundation
import UIKit

// DataSource для UITableView списка найденных/отфильтрованных песен
class SearchResultsDataSource: NSObject, UITableViewDataSource {
    
    // ViewController для отображение списка найденных/отфильтрованных песен
    var searchResultsViewController: SearchResultsViewController!
    
    // Отфильтрованный массив объектов Song, содержащих инфо о песнях
    var filteredSongs: [Song] = []
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Метод DataSource, возвращает число ячеек
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredSongs.count == 0 { // если список песен пуст, скрываем UITableView, вместо него отображаем сообщение что ничего не найдено
            tableView.isHidden = true
            searchResultsViewController.notFound1.isHidden = false
            searchResultsViewController.notFound2.isHidden = false
        } else { // иначе отображаем все наоборот
            tableView.isHidden = false
            searchResultsViewController.notFound1.isHidden = true
            searchResultsViewController.notFound2.isHidden = true
        }
        return filteredSongs.count
    }
    
    // Метод DataSource для заполнения UITableView с инфо
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear

        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 20.0)
        cell.textLabel?.textColor = UIColor(red: 85.0 / 255.0, green: 89.0 / 255.0, blue: 102.0 / 255.0, alpha: 1.0)
        cell.textLabel?.text = String(indexPath.row + 1)
        
        let artistLabel = UILabel()
        artistLabel.numberOfLines = 0
        artistLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 12.0)
        artistLabel.textColor = UIColor(red: 224.0 / 255.0, green: 225.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
        artistLabel.text = filteredSongs[indexPath.row].info
        artistLabel.sizeToFit()
        
        cell.contentView.addSubview(artistLabel)
        
        // cell left margin зависит от ширины экрана
        let diff = (searchResultsViewController.view.frame.width - 320.0) / 2.0 * 0.15
        ViewController.performAutolayoutConstants(subview: artistLabel, view: cell.contentView, left: 50.0 + diff, right: 0.0, top: 0, bottom: 0)
        
        return cell
    }
}
