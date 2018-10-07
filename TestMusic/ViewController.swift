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
    
    private let arrowButton = UIButton()
    private let searchResultsViewController = SearchResultsViewController()
    
    func startSearch(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.975, y: 0.96)
        },
        completion: {finish in UIButton.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform.identity
        })
        })
        
        navigationController!.pushViewController(searchResultsViewController, animated: true)
        view.endEditing(true)
    }
    
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
    
    func textFieldDidChange() {
        if searchBar.text!.characters.count > 0 {
            arrowButton.isHidden = false
        } else {
            arrowButton.isHidden = true
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
        
        foreground.frame = CGRect(x: -55, y: 20, width: 425, height: 568 / 2 - 20)
        foreground.image = UIImage(named: "foreground.png")
        view.addSubview(foreground)
        
        welcome1.textAlignment = .center
        welcome1.textColor = .white
        welcome1.font = UIFont(name: "SFProDisplay-Ultralight", size: 34.0)
        welcome1.text = "FIND YOUR MUSIC"
        
        welcome2.textAlignment = .center
        welcome2.textColor = .white
        welcome2.font = UIFont(name: "SFProDisplay-Ultralight", size: 34.0)
        welcome2.text = "ON ITUNES"
        
        searchBar.delegate = self
        searchBar.backgroundColor = .clear
        searchBar.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        
        searchBar.layer.cornerRadius = 20.0
        searchBar.layer.borderWidth = 2.0
        searchBar.layer.borderColor = UIColor.white.cgColor
        
        searchBar.font = UIFont(name: "SFProDisplay-Ultralight", size: 12.0)
        searchBar.textColor = .gray
        searchBar.text = "\tType anything to search"
        
        arrowButton.backgroundColor = .clear
        arrowButton.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        arrowButton.addTarget(self, action: #selector(startSearch(_:)), for: .touchUpInside)
        arrowButton.setTitle("→", for: .normal)
        searchBar.rightView = arrowButton
        searchBar.rightViewMode = .always
        arrowButton.isHidden = true
        
        view.addSubview(welcome1)
        ViewController.performAutolayoutConstants(subview: welcome1, view: view, left: 0.0, right: 0.0, top: 568.0 / 4 - 10, bottom: -568.0 / 2 - 10)
        
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
        
        let bt = UIButton(type: .custom)
        bt.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        bt.backgroundColor = .red
        bt.setTitle("111", for: .normal)
        
        let backItem = UIBarButtonItem(customView: bt)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        label.text = "?"
        label.textColor = .red
        
        backItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "SFProDisplay-Ultralight", size: 20.0)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
        backItem.title = "Summer"
        
        var back = UIImage(named: "back.png")!
        back = imageWithImage(image: back, scaledToSize: CGSize(width: 6, height: 10))
        
        navigationController!.navigationBar.backIndicatorImage = back
        navigationController!.navigationBar.backIndicatorTransitionMaskImage = back
        navigationController!.navigationBar.topItem!.backBarButtonItem = backItem
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

