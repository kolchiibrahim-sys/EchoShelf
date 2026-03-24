//
//  AuthorViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 23.03.26.
//
import UIKit
import Kingfisher

final class AuthorDetailViewController: UIViewController{
    private let viewModel: AuthorDetailViewModel
    
    init(author: Author) {
        self.viewModel = AuthorDetailViewModel(author: author)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var backButton: UIButton = {
           var config = UIButton.Configuration.plain()
           config.image = UIImage(systemName: "chevron.left")
           config.baseForegroundColor = .white
           let btn = UIButton(configuration: config)
           btn.translatesAutoresizingMaskIntoConstraints = false
           return btn
       }()
    
    private lazy var photoImageView: UIImageView = {
        let iv = UIImageView()
        return iv
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 60
        iv.backgroundColor = UIColor(named: "FillGlass")
        iv.translatesAutoresizingMaskIntoConstraints = false
    }()
    
    private lazy var bioLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "Audiobooks by Ibrahim Kolchi"
        lbl.font = .systemFont(ofSize: 20, weight: .bold)
        lbl.textColor = UIColor(named: "OnDarkTextPrimary")
        return lbl
        lbl.translatesAutoresizingMaskIntoConstraints = false
    }()
}
