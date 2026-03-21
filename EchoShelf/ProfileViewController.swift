//
//  Profile.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//

import UIKit
import FirebaseAuth

final class ProfileViewController: UIViewController {

    var onLogout: (() -> Void)?

    private let viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel = ProfileViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header
    private let headerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let avatarContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#1E3A5F")
        v.layer.cornerRadius = 40
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor(hex: "#4A90E2").withAlphaComponent(0.5).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let initialsLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 26, weight: .bold)
        l.textColor = UIColor(hex: "#4A90E2")
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emailLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor(white: 1, alpha: 0.5)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#0D1117")
        title = "Profil"
        navigationController?.navigationBar.prefersLargeTitles = false
        setupScrollView()
        setupHeader()
        setupSections()
        populateData()
        bindViewModel()
    }

    // MARK: - Setup

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func setupHeader() {
        contentView.addSubview(headerView)
        headerView.addSubview(avatarContainer)
        avatarContainer.addSubview(initialsLabel)
        headerView.addSubview(nameLabel)
        headerView.addSubview(emailLabel)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            avatarContainer.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            avatarContainer.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 80),
            avatarContainer.heightAnchor.constraint(equalToConstant: 80),
            avatarContainer.topAnchor.constraint(equalTo: headerView.topAnchor),
            avatarContainer.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),

            initialsLabel.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),

            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)
        ])
    }

    private func setupSections() {
        let sections: [(title: String, rows: [(icon: String, iconBg: String, title: String, detail: String?, action: () -> Void)])] = [
            ("ACCOUNT", [
                ("person.fill", "#3A6BC4", "Şəxsi Məlumat", nil, { [weak self] in self?.showSettings() }),
                ("lock.fill", "#5C4BC4", "Şifrə və Təhlükəsizlik", nil, { [weak self] in self?.showSettings() }),
                ("creditcard.fill", "#2E7D52", "Abunəlik", "Aktiv", { [weak self] in self?.showSettings() })
            ]),
            ("YADDAŞ", [
                ("internaldrive.fill", "#C47B2E", "Yaddaş və Keş", nil, { [weak self] in self?.showStorageCache() })
            ]),
            ("HAQQINDA", [
                ("info.circle.fill", "#555", "Versiya", Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0", {}),
                ("doc.text.fill", "#555", "İstifadə Şərtləri", nil, {}),
                ("hand.raised.fill", "#555", "Məxfilik Siyasəti", nil, {})
            ])
        ]

        var lastBottom = headerView.bottomAnchor
        var lastView: UIView = headerView

        for (sIdx, section) in sections.enumerated() {
            let headerLabel = makeSectionHeader(section.title)
            contentView.addSubview(headerLabel)
            NSLayoutConstraint.activate([
                headerLabel.topAnchor.constraint(equalTo: lastBottom, constant: sIdx == 0 ? 28 : 24),
                headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
            ])
            lastBottom = headerLabel.bottomAnchor
            lastView = headerLabel

            let card = makeCard()
            contentView.addSubview(card)
            NSLayoutConstraint.activate([
                card.topAnchor.constraint(equalTo: lastBottom, constant: 8),
                card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
            ])

            var prevRowBottom = card.topAnchor
            for (rIdx, row) in section.rows.enumerated() {
                let rowView = makeRow(icon: row.icon, iconBg: row.iconBg, title: row.title, detail: row.detail, showDivider: rIdx < section.rows.count - 1, action: row.action)
                card.addSubview(rowView)
                NSLayoutConstraint.activate([
                    rowView.topAnchor.constraint(equalTo: prevRowBottom),
                    rowView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
                    rowView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
                    rowView.heightAnchor.constraint(equalToConstant: 54)
                ])
                prevRowBottom = rowView.bottomAnchor
            }
            NSLayoutConstraint.activate([
                card.bottomAnchor.constraint(equalTo: prevRowBottom)
            ])

            lastBottom = card.bottomAnchor
            lastView = card
        }

        // Logout button
        let logoutBtn = makeLogoutButton()
        contentView.addSubview(logoutBtn)
        NSLayoutConstraint.activate([
            logoutBtn.topAnchor.constraint(equalTo: lastBottom, constant: 32),
            logoutBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            logoutBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            logoutBtn.heightAnchor.constraint(equalToConstant: 52),
            logoutBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
        _ = lastView
    }

    // MARK: - Factory

    private func makeSectionHeader(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(white: 1, alpha: 0.35)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func makeCard() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#161B22")
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor(white: 1, alpha: 0.07).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    private func makeRow(icon: String, iconBg: String, title: String, detail: String?, showDivider: Bool, action: @escaping () -> Void) -> UIView {
        let container = UIControl()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addAction(UIAction { _ in action() }, for: .touchUpInside)

        container.addTarget(self, action: #selector(rowHighlight(_:)), for: .touchDown)
        container.addTarget(self, action: #selector(rowUnhighlight(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        let iconBg2 = UIView()
        iconBg2.backgroundColor = UIColor(hex: iconBg).withAlphaComponent(0.2)
        iconBg2.layer.cornerRadius = 8
        iconBg2.translatesAutoresizingMaskIntoConstraints = false

        let iconImg = UIImageView(image: UIImage(systemName: icon))
        iconImg.tintColor = UIColor(hex: iconBg)
        iconImg.contentMode = .scaleAspectFit
        iconImg.translatesAutoresizingMaskIntoConstraints = false

        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 15)
        titleLbl.textColor = .white
        titleLbl.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor(white: 1, alpha: 0.3)
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false

        iconBg2.addSubview(iconImg)
        container.addSubview(iconBg2)
        container.addSubview(titleLbl)
        container.addSubview(chevron)

        NSLayoutConstraint.activate([
            iconBg2.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            iconBg2.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconBg2.widthAnchor.constraint(equalToConstant: 32),
            iconBg2.heightAnchor.constraint(equalToConstant: 32),

            iconImg.centerXAnchor.constraint(equalTo: iconBg2.centerXAnchor),
            iconImg.centerYAnchor.constraint(equalTo: iconBg2.centerYAnchor),
            iconImg.widthAnchor.constraint(equalToConstant: 16),
            iconImg.heightAnchor.constraint(equalToConstant: 16),

            titleLbl.leadingAnchor.constraint(equalTo: iconBg2.trailingAnchor, constant: 12),
            titleLbl.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 12)
        ])

        if let detail = detail {
            let detailLbl = UILabel()
            detailLbl.text = detail
            detailLbl.font = .systemFont(ofSize: 13)
            detailLbl.textColor = UIColor(white: 1, alpha: 0.4)
            detailLbl.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(detailLbl)
            NSLayoutConstraint.activate([
                detailLbl.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -6),
                detailLbl.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
        }

        if showDivider {
            let div = UIView()
            div.backgroundColor = UIColor(white: 1, alpha: 0.06)
            div.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(div)
            NSLayoutConstraint.activate([
                div.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                div.leadingAnchor.constraint(equalTo: titleLbl.leadingAnchor),
                div.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                div.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }

        return container
    }

    private func makeLogoutButton() -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = "Çıxış"
        config.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        config.imagePadding = 8
        config.baseBackgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        config.baseForegroundColor = .systemRed
        config.cornerStyle = .large
        let btn = UIButton(configuration: config)
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.3).cgColor
        btn.layer.cornerRadius = 14
        btn.layer.masksToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        return btn
    }

    // MARK: - Data

    private func populateData() {
        initialsLabel.text = viewModel.initials
        nameLabel.text = viewModel.displayName
        emailLabel.text = viewModel.email
    }

    private func bindViewModel() {
        viewModel.onLogout = { [weak self] in
            self?.onLogout?()
        }
    }

    // MARK: - Navigation

    private func showSettings() {
        let vc = SettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showStorageCache() {
        let vc = StorageCacheViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Actions

    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Çıxış", message: "Hesabınızdan çıxmaq istədiyinizə əminsiniz?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ləğv et", style: .cancel))
        alert.addAction(UIAlertAction(title: "Çıxış", style: .destructive) { [weak self] _ in
            self?.viewModel.logout()
        })
        present(alert, animated: true)
    }

    @objc private func rowHighlight(_ sender: UIControl) {
        UIView.animate(withDuration: 0.1) { sender.alpha = 0.6 }
    }

    @objc private func rowUnhighlight(_ sender: UIControl) {
        UIView.animate(withDuration: 0.2) { sender.alpha = 1 }
    }
}
