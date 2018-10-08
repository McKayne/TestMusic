//
//  ViewController.swift
//  TestMusic
//
//  Created by Nikolay Taran on 05.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit
import QuartzCore

// ViewController для отображение окна поиска
class ViewController: UIViewController, UITextFieldDelegate {
    
    // Фоновые изображения
    private let background = UIImageView(), foreground = UIImageView()
    
    // Строки приветствия
    private let welcome1 = UILabel(), welcome2 = UILabel()
    
    // Поле поиска
    private let searchBar = UITextField()
    private var isTextChanged = false
    
    // Кнопка →
    private let arrowButton = UIButton()
    
    // Кастомный backBarButton
    private let backItem = UIBarButtonItem()
    
    // ViewController для отображение списка найденных/отфильтрованных песен
    private let searchResultsViewController = SearchResultsViewController()
    
    // При слишком длинном title в backBarButtonItem оно просто не будет отображаться, выводя вместо этого дефолтное "Back"
    // Для предотвращения этого необходимо обрезать title при превышении определенной длины
    // Пример: "Mississippi" может являться допустимым title
    // Однако "Mississippi queen" уже будет слишко длинным, обрезаем до "Mississippi..."
    static func cutTitle(uncut: String, limit: Int) -> String {
        var chars = Array(uncut.characters)
        if chars.count > limit {
            var cut: [Character] = []
            for i in 0..<limit {
                cut.append(chars[i])
            }
            for _ in 0..<3 {
                cut.append(".")
            }
            return String(cut)
        } else {
            return uncut
        }
    }
    
    // Селектор для начала поиска
    func startSearch(_ sender: UIButton) {
        // Анимация arrowButton
        UIButton.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.975, y: 0.96)
        },
        completion: {finish in UIButton.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform.identity
        })
        })
        
        backItem.title = ViewController.cutTitle(uncut: searchBar.text!, limit: 8)

        searchResultsViewController.searchText = searchBar.text!
        searchResultsViewController.loadResults()
        navigationController!.pushViewController(searchResultsViewController, animated: true)
        view.endEditing(true)
    }
    
    // Метод делегата UITextField, вызывается после тапа по searchBar
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !isTextChanged {
            isTextChanged = true
            searchBar.textAlignment = .center
            searchBar.text = ""
            searchBar.textColor = .white
        }
    }
    
    // Метод делегата UITextField, вызывается после того, как пользователь завершил редактирование текста в searchBar
    func textFieldDidEndEditing(_ textField: UITextField) {
        if searchBar.text?.characters.count == 0 {
            isTextChanged = false
            searchBar.textColor = .gray
            searchBar.textAlignment = .left
            searchBar.text = "\tType anything to search"
        }
    }
    
    // Селектор изменения строки поиска
    func textFieldDidChange() {
        // Кнопка → появляется только при непустом поле
        if searchBar.text!.characters.count > 0 {
            arrowButton.isHidden = false
        } else {
            arrowButton.isHidden = true
        }
    }
    
    // Применение AutoLayout к элементу на экране
    static func performAutolayoutConstants(subview: UIView, view: UIView, left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left).isActive = true
        subview.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right).isActive = true
        subview.topAnchor.constraint(equalTo: view.topAnchor, constant: top).isActive = true
        subview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom).isActive = true
    }
    
    // Селектор скрытия клавиатуры
    func dismissKeyboardOnTap() {
        view.endEditing(true)
        searchResultsViewController.dismissKeyboardOnTap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Добавляем распознавание жестов для скрытия клавиатуры при тапе по экрану
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardOnTap)))
        
        // Фоновое изображение
        background.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        background.image = UIImage(named: "background.png")
        view.addSubview(background)
        
        foreground.frame = CGRect(x: -view.frame.width * 0.175, y: 20, width: view.frame.width * 1.328125, height: view.frame.height / 2 - 20)
        foreground.image = UIImage(named: "foreground.png")
        view.addSubview(foreground)
        
        // Строка приветствия 1
        welcome1.textAlignment = .center
        welcome1.textColor = .white
        welcome1.font = UIFont(name: "HelveticaNeue-Thin", size: 30.0)
        welcome1.text = "FIND YOUR MUSIC"
        
        // Строка приветствия 2
        welcome2.textAlignment = .center
        welcome2.textColor = .white
        welcome2.font = UIFont(name: "HelveticaNeue-Thin", size: 30.0)
        welcome2.text = "ON ITUNES"
        
        // Поле поиска
        searchBar.delegate = self
        searchBar.backgroundColor = .clear
        searchBar.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        
        searchBar.layer.cornerRadius = 20.0
        searchBar.layer.borderWidth = 2.0
        searchBar.layer.borderColor = UIColor.white.cgColor
        
        searchBar.font = UIFont(name: "HelveticaNeue-Thin", size: 12.0)
        searchBar.textColor = .gray
        searchBar.text = "\tType anything to search"
        
        // Кнопка →
        arrowButton.backgroundColor = .clear
        arrowButton.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        arrowButton.addTarget(self, action: #selector(startSearch(_:)), for: .touchUpInside)
        arrowButton.setTitle("→", for: .normal)
        searchBar.rightView = arrowButton
        searchBar.rightViewMode = .always
        arrowButton.isHidden = true
        
        view.addSubview(welcome1)
        ViewController.performAutolayoutConstants(subview: welcome1, view: view, left: 0.0, right: 0.0, top: view.frame.height / 4 - 10, bottom: -view.frame.height / 2 - 10)
        
        view.addSubview(welcome2)
        ViewController.performAutolayoutConstants(subview: welcome2, view: view, left: 0.0, right: 0.0, top: view.frame.height / 4 + 20, bottom: -view.frame.height / 2 + 20)
        
        view.addSubview(searchBar)
        ViewController.performAutolayoutConstants(subview: searchBar, view: view, left: 20.0, right: -20.0, top: view.frame.height / 2 - 30, bottom: -view.frame.height / 2 + 50 - 30)
        
        // Делаем фон navigationBar прозрачным
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController!.navigationBar.shadowImage = UIImage()
        navigationController!.navigationBar.isTranslucent = true
        
        // navigationBar не является subview для self.view, соответственно для него необходимо добавить распознавание жестов для скрытия клавиатуры при тапе
        let navBarGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardOnTap))
        navigationController!.navigationBar.addGestureRecognizer(navBarGestureRecognizer)
        navBarGestureRecognizer.cancelsTouchesInView = false
        
        // Кастомный backBarButtonItem
        backItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 20.0)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
        
        // Кастомный back arrow
        var back = UIImage(named: "back.png")!
        back = imageWithImage(image: back, scaledToSize: CGSize(width: 6, height: 10)) // ресайзим до размера 6x10
        
        navigationController!.navigationBar.backIndicatorImage = back
        navigationController!.navigationBar.backIndicatorTransitionMaskImage = back
        navigationController!.navigationBar.topItem!.backBarButtonItem = backItem
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    // Метод ресайзинга изображений, применяется для изменения размера back arrow
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent // Т.к. используется темный фон, делаем status bar светлым
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

