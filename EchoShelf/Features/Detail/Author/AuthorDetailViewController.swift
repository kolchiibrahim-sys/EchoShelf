//
//  AuthorDetailViewController.swift
//  EchoShelf
//
import UIKit
import Kingfisher

final class AuthorDetailViewController: UIViewController {

    private let viewModel: AuthorDetailViewModel

    init(author: Author) {
        self.viewModel = AuthorDetailViewModel(author: author)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

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
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 60
        iv.backgroundColor = UIColor(named: "FillGlass")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        lbl.textColor = UIColor(named: "OnDarkTextPrimary")
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var bioLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15)
        lbl.textColor = UIColor(named: "OnDarkTextSecondary")
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var booksTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Audiobooks"
        lbl.font = .systemFont(ofSize: 20, weight: .bold)
        lbl.textColor = UIColor(named: "OnDarkTextPrimary")
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TrendingBookCell.self, forCellWithReuseIdentifier: TrendingBookCell.identifier)
        return cv
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = UIColor(named: "PrimaryGradientStart")
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    private var collectionHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupUI()
        setupActions()
        bindViewModel()
        viewModel.fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(backButton)
        view.addSubview(activityIndicator)

        contentView.addSubview(photoImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(bioLabel)
        contentView.addSubview(booksTitleLabel)
        contentView.addSubview(collectionView)

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 80),
            photoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: 120),
            photoImageView.heightAnchor.constraint(equalToConstant: 120),

            nameLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            bioLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            bioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            bioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            booksTitleLabel.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 32),
            booksTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            collectionView.topAnchor.constraint(equalTo: booksTitleLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionHeightConstraint,
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }
            switch state {
            case .loading:
                self.activityIndicator.startAnimating()
            case .success:
                self.activityIndicator.stopAnimating()
                self.updateUI()
            case .failure:
                self.activityIndicator.stopAnimating()
            case .idle:
                break
            }
        }
    }

    private func updateUI() {
        nameLabel.text = viewModel.fullName

        if let photoURL = viewModel.authorDetail?.photoURL {
            photoImageView.kf.setImage(with: photoURL, placeholder: UIImage(systemName: "person.circle.fill"))
        } else {
            photoImageView.image = UIImage(systemName: "person.circle.fill")
            photoImageView.tintColor = UIColor(named: "OnDarkTextSecondary")
        }

        if let bio = viewModel.authorDetail?.bio, !bio.isEmpty {
            bioLabel.text = bio
        } else {
            bioLabel.text = "No biography available."
        }

        let rowCount = ceil(Double(viewModel.books.count) / 2.0)
        collectionHeightConstraint.constant = rowCount * 260
        collectionView.reloadData()
        view.layoutIfNeeded()
    }

    private func createLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(240))
        )
        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 12)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(240)),
            subitems: [item, item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 8)
        return UICollectionViewCompositionalLayout(section: section)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension AuthorDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.books.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingBookCell.identifier, for: indexPath) as! TrendingBookCell
        cell.configure(with: viewModel.books[indexPath.item])
        return cell
    }
}

extension AuthorDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = viewModel.books[indexPath.item]
        navigationController?.pushViewController(BookDetailViewController(book: book), animated: true)
    }
}
