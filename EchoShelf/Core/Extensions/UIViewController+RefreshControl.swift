//
//  UIViewController+RefreshControl.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 04.04.26.
//
import UIKit

extension UIViewController {
    func addRefreshController(to scrollView:UIScrollView,
                              action: @escaping()-> Void){
        let refresh = UIRefreshControl()
        refresh.addAction(UIAction { _ in action () },
                          for: .valueChanged)
        scrollView.refreshControl = refresh
        }
    }

