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

// ViewController для отображение списка найденных/отфильтрованных песен
class SearchResultsViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var searchText: String! // Текст для поиска
    
    private let background = UIImageView() // Фоновое изображение
    private let activity = UIActivityIndicatorView() // Индикатор загрузки
    
    private let songsFound = UILabel() // UIlabel с количеством подходящих (найденных/отфильтрованных) песен
    
    let notFound1 = UILabel(), notFound2 = UILabel()
    
    private let filterBar = UITextField()
    private var isTextChanged = false
    private let arrowButton = UIButton()
    
    private let resultsTableView = UITableView()
    private let searchResultsDataSource = SearchResultsDataSource()
    private var songs: [Song] = []
    
    // ViewController для отображения информации о песне
    private let songViewController = SongViewController()
    
    // UITapGestureRecognizer конфликтует с выделением UITableView, поэтому тапы по UITableView необходимо исключать
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: resultsTableView))! {
            return false
        }
        return true
    }
    
    // Селектор скрытия клавиатуры
    func dismissKeyboardOnTap() {
        view.endEditing(true)
    }
    
    // Метод делегата UITextField, вызывается после тапа по filterBar
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !isTextChanged {
            isTextChanged = true
            filterBar.textAlignment = .center
            filterBar.text = ""
            filterBar.textColor = .white
        }
    }
    
    // Метод делегата UITextField, вызывается после того, как пользователь завершил редактирование текста в filterBar
    func textFieldDidEndEditing(_ textField: UITextField) {
        if filterBar.text?.characters.count == 0 {
            isTextChanged = false
            filterBar.textColor = .gray
            filterBar.textAlignment = .left
            filterBar.text = "\tFilter"
        }
    }
    
    // Селектор фильтрации списка песен при изменении строки фильтра
    func textFieldDidChange() {
        // Кнопка → появляется только при непустом поле
        if filterBar.text!.characters.count > 0 {
            arrowButton.isHidden = false
        } else {
            arrowButton.isHidden = true
        }
        
        filterSongs(filter: filterBar.text!) // фильтрация
        songsFound.text = "\(searchResultsDataSource.filteredSongs.count) songs" // новое число песен, попадающих под фильтр
        resultsTableView.reloadData() // обновление списка песен
    }
    
    // Селектор для завершения редактирования поля фильтра и вызова метода фильтрации
    func dismissKeyboardAndFilter(sender: UIButton) {
        view.endEditing(true)
        filterSongs(filter: filterBar.text!)
        songsFound.text = "\(searchResultsDataSource.filteredSongs.count) songs"
        resultsTableView.reloadData()
    }
    
    // Фильтрация списка песен по строке
    private func filterSongs(filter: String) {
        // Если искомая строка непуста, то фильтруем список
        if filter.characters.count > 0 {
            searchResultsDataSource.filteredSongs = []
            
            // Песня подходит фильтру если
            // 1) или ее название содержит искомую строку
            // 2) или имя ее исполнителя содержит искомую строку
            // 3) или название альбома содержит искомую строку
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
        } else { // иначе считается, что фильтрация не нужна, отображаем весь список найденных песен
            searchResultsDataSource.filteredSongs = songs
        }
    }
    
    // Метод делегата UTableView, возвращает высоту ячейки по формуле (число строк в строке(название + исполнитель) + 1) * 15
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(searchResultsDataSource.filteredSongs[indexPath.row].lineCount + 1) * 15.0
    }
    
    // Метод делегата UTableView, вызывается при тапе по песне в списке, отображает ViewController с подробным инфо о песне
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let backItem = UIBarButtonItem()
        backItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 20.0)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
        
        let title: String! = searchResultsDataSource.filteredSongs[indexPath.row].trackName!
        backItem.title = ViewController.cutTitle(uncut: title, limit: 8)
        
        navigationController!.navigationBar.topItem!.backBarButtonItem = backItem
        
        songViewController.song = searchResultsDataSource.filteredSongs[indexPath.row]
        songViewController.infoTableView.reloadData()
        navigationController?.pushViewController(songViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Получение ответа API в виде JSON, с последующей его десеариализацией в виде массива объектов Song, содержащих инфо о песне
    func parseJSON() {
        let request = searchText.replacingOccurrences(of: " ", with: "+").lowercased() // строка запроса в виде "my+compound+request"
        
        if let url = URL(string: "https://itunes.apple.com/search?term=\(request)") { // URL для запроса
            do {
                let contents = try String(contentsOf: url) // ответ API в виде текстового JSON
                
                let parseData = try JSONSerialization.jsonObject(with: contents.data(using: .utf8)!) as! [String: Any] // десериализация
                
                if let nested = parseData["results"] as? [[String: Any]] {
                    for result in nested {
                        if let key = result["kind"] {
                            if String(describing: key) == "song" { // если в информации о текущем объекте есть соответствие kind=song
                                let song = Song() // создаем новый объект Song и заполняем его информацией о песне
                                
                                song.artistName = String(describing: result["artistName"]!) // исполнитель
                                song.collectionName = String(describing: result["collectionName"]!) // альбом
                                song.trackName = String(describing: result["trackName"]!) // название песни
                                song.artworkURL = URL(string: String(describing: result["artworkUrl100"]!)) // URL на артворк
                                song.genre = String(describing: result["primaryGenreName"]!) // жанр
                                
                                song.releaseDate = String(describing: result["releaseDate"]!) // год релиза
                                
                                song.discNumber = String(describing: result["discNumber"]!) // № диска
                                song.discCount = String(describing: result["discCount"]!) // всего дисков
                                song.trackNumber = String(describing: result["trackNumber"]!) // № песни
                                song.trackCount = String(describing: result["trackCount"]!) // всего песен в альбоме
                                
                                song.trackPrice = String(describing: result["trackPrice"]!) // цена песни в iTunes
                                song.collectionPrice = String(describing: result["collectionPrice"]!) // цена альбома в iTunes
                                
                                song.previewURL = URL(string: String(describing: result["previewUrl"]!)) // URL на образец для прослушивания
                                
                                song.trackTimeMillis = String(describing: result["trackTimeMillis"]!) // длительность в миллисекундах
                                
                                song.info = "\(song.trackName ?? "")\n\(song.artistName ?? ""), \(song.collectionName ?? "")" // инфо о песне в виде "Track by Artist"
                                song.cellFont = UIFont(name: "HelveticaNeue-Thin", size: 12.0) // шрифт, которым далее будет отображаться инфо в UITableViewCell
                                
                                song.lineCount = song.numberOfLines(string: song.info) // количество строк, который будет занимать инфо в multiline UILabel
                                
                                songs.append(song) // добавление инфо о песне в массив
                            }
                        }
                    }
                }
            } catch {
                print("JSON deserialization error")
            }
        }
    }
    
    // Поиск результатов с использованием iTunes API с их последующим отображением
    func loadResults() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true // устанавливаем индикатор использования сети
        
        activity.isHidden = false
        activity.startAnimating()
        songsFound.isHidden = true
        notFound1.isHidden = true
        notFound2.isHidden = true
        filterBar.isHidden = true
        resultsTableView.isHidden = true
        
        songs = []
        
        // Поиск и загрузка результатов для отображения длительный процесс, поэтому выполняем его асинхронно
        OperationQueue().addOperation {
            self.parseJSON()
            
            // Все операции с изменеием свойств UIView необходимо выполнять в главном потоке
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
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Добавляем распознавание жестов для скрытия клавиатуры при тапе по экрану
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardOnTap))
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        
        // Фоновое изображение
        background.frame = CGRect(x: 0, y: 0, width: 320, height: 568)
        background.image = UIImage(named: "background.png")
        view.addSubview(background)
        
        // Индикатор загрузки
        activity.color = .white
        view.addSubview(activity)
        ViewController.performAutolayoutConstants(subview: activity, view: view, left: 320.0 / 2 - 15, right: -320.0 / 2 + 15, top: 568.0 / 2 - 15, bottom: -568.0 / 2 + 15)
        
        // UIlabel с количеством подходящих (найденных/отфильтрованных) песен
        songsFound.font = UIFont(name: "HelveticaNeue-Thin", size: 12.0)
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
        
        filterBar.font = UIFont(name: "HelveticaNeue-Thin", size: 12.0)
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent // Т.к. используется темный фон, делаем status bar светлым
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Если пользователь вернулся на экран поиска, сбрасываем фильтр и возвращаем UITableView в начало
        if navigationController!.visibleViewController is ViewController {
            
            isTextChanged = false
            filterBar.textColor = .gray
            filterBar.textAlignment = .left
            filterBar.text = "\tFilter"
            
            if searchResultsDataSource.filteredSongs.count > 0 {
                resultsTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        view.endEditing(true) // смена экрана, скрываем клавиатуру
    }
}
