//
//  ViewController.swift
//  TestMusic
//
//  Created by Nikolay Taran on 05.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController, UITextFieldDelegate {
    
    private let background = UIImageView(), foreground = UIImageView()
    private let welcome1 = UILabel(), welcome2 = UILabel()
    
    private let searchBar = UITextField()
    private var isTextChanged = false
    
    private let searchResultsViewController = SearchResultsViewController()
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !isTextChanged {
            isTextChanged = true
            searchBar.textAlignment = .center
            searchBar.text = ""
            searchBar.textColor = .white
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if searchBar.text?.characters.count == 0 {
            isTextChanged = false
            searchBar.textColor = .gray
            searchBar.textAlignment = .left
            searchBar.text = "\tType anything to search"
        }
    }
    
    static func performAutolayoutConstants(subview: UIView, view: UIView, left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left).isActive = true
        subview.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right).isActive = true
        subview.topAnchor.constraint(equalTo: view.topAnchor, constant: top).isActive = true
        subview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom).isActive = true
    }
    
    func dismissKeyboardOnTap(dummy: Any) {
        view.endEditing(true)
        searchResultsViewController.dismissKeyboardOnTap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardOnTap)))
        
        background.frame = CGRect(x: 0, y: 0, width: 320, height: 568)
        background.image = UIImage(named: "background.png")
        view.addSubview(background)
        
        foreground.frame = CGRect(x: -55, y: 20, width: 415, height: 568 / 2 - 20)
        foreground.image = UIImage(named: "foreground.png")
        view.addSubview(foreground)
        
        welcome1.textAlignment = .center
        welcome1.textColor = .white
        welcome1.font = UIFont(name: "SFProDisplay-Ultralight", size: 20.0)
        welcome1.text = "FIND YOUR MUSIC"
        
        welcome2.textAlignment = .center
        welcome2.textColor = .white
        welcome2.font = UIFont(name: "SFProDisplay-Ultralight", size: 20.0)
        welcome2.text = "ON ITUNES"
        
        searchBar.delegate = self
        searchBar.backgroundColor = .clear
        
        searchBar.layer.cornerRadius = 20.0
        searchBar.layer.borderWidth = 2.0
        searchBar.layer.borderColor = UIColor.white.cgColor
        
        searchBar.font = UIFont(name: "SFProDisplay-Ultralight", size: 12.0)
        searchBar.textColor = .gray
        searchBar.text = "\tType anything to search"
        
        view.addSubview(welcome1)
        ViewController.performAutolayoutConstants(subview: welcome1, view: view, left: 0.0, right: 0.0, top: 568.0 / 4, bottom: -568.0 / 2)
        
        view.addSubview(welcome2)
        ViewController.performAutolayoutConstants(subview: welcome2, view: view, left: 0.0, right: 0.0, top: 568.0 / 4 + 20, bottom: -568.0 / 2 + 20)
        
        view.addSubview(searchBar)
        ViewController.performAutolayoutConstants(subview: searchBar, view: view, left: 20.0, right: -20.0, top: 250, bottom: -280)
        
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController!.navigationBar.shadowImage = UIImage()
        navigationController!.navigationBar.isTranslucent = true
        
        let navBarGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardOnTap))
        navigationController!.navigationBar.addGestureRecognizer(navBarGestureRecognizer)
        navBarGestureRecognizer.cancelsTouchesInView = false
        
        let backItem = UIBarButtonItem()
        backItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "SFProDisplay-Ultralight", size: 20.0)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
        backItem.title = "Summer"
        navigationController!.navigationBar.topItem!.backBarButtonItem = backItem
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        
        navigationController!.pushViewController(searchResultsViewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

