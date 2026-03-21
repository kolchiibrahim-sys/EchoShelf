//
//  Library.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//

import UIKit

final class LibraryViewController: UIViewController {

    weak var coordinator: LibraryCoordinator?
    private let viewModel: LibraryViewModel
    private var collectionView: UICollectionView!

    private let wallView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let wallGradient = CAGradientLayer()

    private let lampGlow: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#F5A623").withAlphaComponent(0.07)
        v.layer.cornerRadius = 120
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = false
        return v
    }()

    private let lampIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "lamp.desk.fill"))
        iv.tintColor   = UIColor(hex: "#F5A623").withAlphaComponent(0.45)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = false
        return iv
    }()

    init(viewModel: LibraryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupNavBar()
        setupCollectionView()
        setupDecorations()
        bindViewModel()
        viewModel.loadLibrary()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        viewModel.loadLibrary()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        wallGradient.frame = wallView.bounds
    }
}

private extension LibraryViewController {

    func setupBackground() {
        view.backgroundColor = UIColor(named: "AppBackground")

        wallGradient.colors = [
            UIColor(hex: "#1A0E06").cgColor,
            UIColor(hex: "#241508").cgColor,
            UIColor(hex: "#1A0E06").cgColor,
        ]
        wallGradient.locations = [0, 0.5, 1]
        wallGradient.startPoint = CGPoint(x: 0, y: 0)
        wallGradient.endPoint   = CGPoint(x: 0, y: 1)
        wallView.layer.insertSublayer(wallGradient, at: 0)

        view.addSubview(wallView)
        NSLayoutConstraint.activate([
            wallView.topAnchor.constraint(equalTo: view.topAnchor),
            wallView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            wallView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wallView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func setupNavBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func setupDecorations() {
        view.addSubview(lampGlow)
        view.addSubview(lampIcon)

        NSLayoutConstraint.activate([
            lampGlow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 60),
            lampGlow.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -20),
            lampGlow.widthAnchor.constraint(equalToConstant: 240),
            lampGlow.heightAnchor.constraint(equalToConstant: 240),

            lampIcon.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lampIcon.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            lampIcon.widthAnchor.constraint(equalToConstant: 28),
            lampIcon.heightAnchor.constraint(equalToConstant: 28),
        ])
    }

    func setupCollectionView() {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout()
        )
        collectionView.backgroundColor         = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource              = self
        collectionView.delegate                = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset            = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)

        collectionView.register(BookSpineCell.self,        forCellWithReuseIdentifier: BookSpineCell.identifier)
        collectionView.register(LibraryEmptyCell.self,     forCellWithReuseIdentifier: LibraryEmptyCell.identifier)
        collectionView.register(AudioDiskCell.self,        forCellWithReuseIdentifier: AudioDiskCell.identifier)

        collectionView.register(
            LibraryShelfHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: LibraryShelfHeader.identifier
        )
        collectionView.register(
            ShelfWoodView.self,
            forSupplementaryViewOfKind: "shelf-wood",
            withReuseIdentifier: ShelfWoodView.identifier
        )

        view.addSubview(collectionView)

        let titleLabel = UILabel()
        titleLabel.text      = "My Library"
        titleLabel.font      = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#E8D5B0")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

private extension LibraryViewController {

    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self,
                  let section = LibrarySection(rawValue: sectionIndex) else { return nil }
            return self.shelfLayout(for: section)
        }
    }

    func audioshelfLayout() -> NSCollectionLayoutSection {
        let isEmpty = viewModel.isEmpty(for: .audiobooks)

        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: isEmpty ? .fractionalWidth(1) : .absolute(110),
                heightDimension: .absolute(isEmpty ? 160 : 140)
            )
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: isEmpty ? .fractionalWidth(1) : .estimated(600),
                heightDimension: .absolute(isEmpty ? 160 : 140)
            ),
            subitems: [item]
        )
        if !isEmpty { group.interItemSpacing = .fixed(12) }

        let layout = NSCollectionLayoutSection(group: group)
        layout.contentInsets = .init(top: 12, leading: 20, bottom: 0, trailing: 20)
        if !isEmpty { layout.orthogonalScrollingBehavior = .continuous }

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(52))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        let woodSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(18))
        let woodFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: woodSize,
            elementKind: "shelf-wood",
            alignment: .bottom
        )
        layout.boundarySupplementaryItems = [header, woodFooter]
        return layout
    }
    func shelfLayout(for section: LibrarySection) -> NSCollectionLayoutSection {
        if section == .audiobooks {
            return audioshelfLayout()
        }
        let isEmpty = viewModel.isEmpty(for: section)

        let itemWidth: NSCollectionLayoutDimension  = isEmpty ? .fractionalWidth(1) : .absolute(48)
        let itemHeight: NSCollectionLayoutDimension = isEmpty ? .absolute(160)      : .absolute(160)

        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: itemWidth, heightDimension: itemHeight)
        )

        let groupWidth: NSCollectionLayoutDimension = isEmpty ? .fractionalWidth(1) : .estimated(800)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: groupWidth, heightDimension: .absolute(160)),
            subitems: [item]
        )
        if !isEmpty {
            group.interItemSpacing = .fixed(4)
        }

        let layout = NSCollectionLayoutSection(group: group)
        layout.contentInsets = .init(top: 12, leading: 20, bottom: 0, trailing: 20)

        if !isEmpty {
            layout.orthogonalScrollingBehavior = .continuous
        }

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(52)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        let woodSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(18)
        )
        let woodFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: woodSize,
            elementKind: "shelf-wood",
            alignment: .bottom
        )

        layout.boundarySupplementaryItems = [header, woodFooter]
        return layout
    }
}

extension LibraryViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        LibrarySection.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let s = LibrarySection(rawValue: section) else { return 0 }
        let items = viewModel.items(for: s)
        return items.isEmpty ? 1 : items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = LibrarySection(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }

        let items = viewModel.items(for: section)

        if items.isEmpty {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: LibraryEmptyCell.identifier,
                for: indexPath
            )
        }

        if section == .audiobooks {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AudioDiskCell.identifier,
                for: indexPath
            ) as! AudioDiskCell
            cell.configure(with: items[indexPath.item])
            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BookSpineCell.identifier,
            for: indexPath
        ) as! BookSpineCell

        cell.configure(with: items[indexPath.item], index: indexPath.item)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: LibraryShelfHeader.identifier,
                for: indexPath
            ) as! LibraryShelfHeader

            guard let section = LibrarySection(rawValue: indexPath.section) else {
                return header
            }
            header.configure(
                title: section.title,
                icon: section.icon,
                count: viewModel.items(for: section).count
            )
            return header
        }

        let wood = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ShelfWoodView.identifier,
            for: indexPath
        )
        return wood
    }
}

extension LibraryViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let section = LibrarySection(rawValue: indexPath.section) else { return }
        let items = viewModel.items(for: section)
        guard !items.isEmpty, indexPath.item < items.count else { return }

        let item = items[indexPath.item]

        if item.type == .audiobook {
            if let cell = collectionView.cellForItem(at: indexPath) as? AudioDiskCell {
                cell.animateSpin()
            }
            coordinator?.openAudiobook(item)
            return
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? BookSpineCell {
            cell.animatePullOut { [weak self] in
                self?.coordinator?.openBook(item)
            }
        } else {
            coordinator?.openBook(item)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        guard let section = LibrarySection(rawValue: indexPath.section) else { return nil }
        let items = viewModel.items(for: section)
        guard !items.isEmpty, indexPath.item < items.count else { return nil }

        let item = items[indexPath.item]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let delete = UIAction(
                title: "Remove from Library",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                guard let self else { return }
                self.coordinator?.confirmDelete(item, from: self) {
                    self.viewModel.delete(item)
                }
            }
            return UIMenu(children: [delete])
        }
    }
}

