//
//  SettingsViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 07.03.26.
//

import UIKit
import FirebaseAuth
final class SettingsViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private var autoPlayEnabled = true
    private var autoDownloadEnabled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "SettingsBackground")!
        title = "Tənzimləmələr"
        navigationController?.navigationBar.tintColor = UIColor(named: "PrimaryAccent")!
        setupScrollView()
        setupSections()
        setupFooter()
    }

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

    private func setupSections() {
        var lastBottom = contentView.topAnchor

        // ACCOUNT
        lastBottom = addSection(title: "HESAB", rows: [
            makeNavRow(icon: "person.fill", iconBg: "IconBlue", title: "Şəxsi Məlumat") {},
            makeNavRow(icon: "lock.fill", iconBg: "IconPurple", title: "Şifrə və Təhlükəsizlik") {},
            makeNavRow(icon: "creditcard.fill", iconBg: "IconGreen", title: "Abunəlik", detail: "Aktiv") {}
        ], topAnchor: lastBottom, topSpacing: 20)

        // PLAYBACK
        let autoPlayToggle = makeToggleRow(icon: "play.circle.fill", iconBg: "IconOrange", title: "Avtomatik oynat", isOn: autoPlayEnabled) { [weak self] val in
            self?.autoPlayEnabled = val
        }
        let audioQualityRow = makeNavRow(icon: "hifi.speaker.fill", iconBg: "IconOrangeSoft", title: "Audio Keyfiyyəti", detail: "Yüksək (Lossless)") { [weak self] in
            self?.showAudioQualityPicker()
        }
        lastBottom = addSection(title: "OXUTMA", rows: [autoPlayToggle, audioQualityRow], topAnchor: lastBottom, topSpacing: 24)

        // STORAGE
        let autoDownloadToggle = makeToggleRow(icon: "arrow.down.circle.fill", iconBg: "IconGreen", title: "Avtomatik yüklə", isOn: autoDownloadEnabled) { [weak self] val in
            self?.autoDownloadEnabled = val
        }
        let clearCacheRow = makeNavRow(icon: "trash.fill", iconBg: "IconDarkRed", title: "Keşi təmizlə", detail: "1.2 GB") { [weak self] in
            self?.confirmClearCache()
        }
        lastBottom = addSection(title: "YADDAŞ", rows: [autoDownloadToggle, clearCacheRow], topAnchor: lastBottom, topSpacing: 24)

        // NOTIFICATIONS
        lastBottom = addSection(title: "BİLDİRİŞLƏR", rows: [
            makeNavRow(icon: "bell.fill", iconBg: "IconRed", title: "Push Bildirişlər") {}
        ], topAnchor: lastBottom, topSpacing: 24)

        // ABOUT
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        lastBottom = addSection(title: "HAQQINDA", rows: [
            makeInfoRow(title: "Versiya", detail: "\(version) (\(build))"),
            makeNavRow(icon: "doc.text.fill", iconBg: "IconGray", title: "İstifadə Şərtləri") {},
            makeNavRow(icon: "hand.raised.fill", iconBg: "IconGray", title: "Məxfilik Siyasəti") {}
        ], topAnchor: lastBottom, topSpacing: 24)

        NSLayoutConstraint.activate([
            lastBottom.constraint(equalTo: contentView.bottomAnchor, constant: -80)
        ])
    }

    @discardableResult
    private func addSection(title: String, rows: [UIView], topAnchor: NSLayoutYAxisAnchor, topSpacing: CGFloat) -> NSLayoutYAxisAnchor {
        let headerLbl = makeSectionHeader(title)
        contentView.addSubview(headerLbl)
        NSLayoutConstraint.activate([
            headerLbl.topAnchor.constraint(equalTo: topAnchor, constant: topSpacing),
            headerLbl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])

        let card = makeCard()
        contentView.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: headerLbl.bottomAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        var prevBottom = card.topAnchor
        for (i, row) in rows.enumerated() {
            card.addSubview(row)
            NSLayoutConstraint.activate([
                row.topAnchor.constraint(equalTo: prevBottom),
                row.leadingAnchor.constraint(equalTo: card.leadingAnchor),
                row.trailingAnchor.constraint(equalTo: card.trailingAnchor),
                row.heightAnchor.constraint(equalToConstant: 54)
            ])
            if i < rows.count - 1 {
                let div = makeDivider()
                card.addSubview(div)
                NSLayoutConstraint.activate([
                    div.bottomAnchor.constraint(equalTo: row.bottomAnchor),
                    div.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 58),
                    div.trailingAnchor.constraint(equalTo: card.trailingAnchor),
                    div.heightAnchor.constraint(equalToConstant: 0.5)
                ])
            }
            prevBottom = row.bottomAnchor
        }
        card.bottomAnchor.constraint(equalTo: prevBottom).isActive = true
        return card.bottomAnchor
    }

    private func setupFooter() {
        let email = Auth.auth().currentUser?.email ?? ""
        let footerLbl = UILabel()
        footerLbl.text = "Daxil olunub: \(email)"
        footerLbl.font = .systemFont(ofSize: 12)
        footerLbl.textColor = UIColor(named: "OnDarkTextFooter")!
        footerLbl.textAlignment = .center
        footerLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(footerLbl)
        NSLayoutConstraint.activate([
            footerLbl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            footerLbl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Row Factories

    private func makeNavRow(icon: String, iconBg: String, title: String, detail: String? = nil, action: @escaping () -> Void) -> UIView {
        let container = UIControl()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addAction(UIAction { _ in action() }, for: .touchUpInside)
        container.addTarget(self, action: #selector(rowHighlight(_:)), for: .touchDown)
        container.addTarget(self, action: #selector(rowUnhighlight(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        let iconBgView = makeIconBg(icon: icon, iconTintAsset: iconBg)
        let titleLbl = makeRowTitle(title)
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor(named: "OnDarkChevron")!
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(iconBgView)
        container.addSubview(titleLbl)
        container.addSubview(chevron)

        NSLayoutConstraint.activate([
            iconBgView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            iconBgView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconBgView.widthAnchor.constraint(equalToConstant: 32),
            iconBgView.heightAnchor.constraint(equalToConstant: 32),
            titleLbl.leadingAnchor.constraint(equalTo: iconBgView.trailingAnchor, constant: 12),
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
            detailLbl.textColor = UIColor(named: "OnDarkTextDetail")!
            detailLbl.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(detailLbl)
            NSLayoutConstraint.activate([
                detailLbl.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -6),
                detailLbl.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
        }
        return container
    }

    private func makeToggleRow(icon: String, iconBg: String, title: String, isOn: Bool, onChange: @escaping (Bool) -> Void) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconBgView = makeIconBg(icon: icon, iconTintAsset: iconBg)
        let titleLbl = makeRowTitle(title)
        let toggle = UISwitch()
        toggle.isOn = isOn
        toggle.onTintColor = UIColor(named: "PrimaryAccent")!
        toggle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addAction(UIAction { _ in onChange(toggle.isOn) }, for: .valueChanged)

        container.addSubview(iconBgView)
        container.addSubview(titleLbl)
        container.addSubview(toggle)

        NSLayoutConstraint.activate([
            iconBgView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            iconBgView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconBgView.widthAnchor.constraint(equalToConstant: 32),
            iconBgView.heightAnchor.constraint(equalToConstant: 32),
            titleLbl.leadingAnchor.constraint(equalTo: iconBgView.trailingAnchor, constant: 12),
            titleLbl.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            toggle.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }

    private func makeInfoRow(title: String, detail: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        let titleLbl = makeRowTitle(title)
        titleLbl.textColor = UIColor(named: "OnDarkTextSecondary")!
        let detailLbl = UILabel()
        detailLbl.text = detail
        detailLbl.font = .systemFont(ofSize: 14)
        detailLbl.textColor = UIColor(named: "OnDarkTextDetail")!
        detailLbl.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLbl)
        container.addSubview(detailLbl)
        NSLayoutConstraint.activate([
            titleLbl.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLbl.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            detailLbl.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            detailLbl.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }

    // MARK: - Shared Helpers

    private func makeIconBg(icon: String, iconTintAsset: String) -> UIView {
        let bg = UIView()
        let base = UIColor(named: iconTintAsset) ?? UIColor(named: "PrimaryAccent")!
        bg.backgroundColor = base.withAlphaComponent(0.2)
        bg.layer.cornerRadius = 8
        bg.translatesAutoresizingMaskIntoConstraints = false
        let img = UIImageView(image: UIImage(systemName: icon))
        img.tintColor = base
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(img)
        NSLayoutConstraint.activate([
            img.centerXAnchor.constraint(equalTo: bg.centerXAnchor),
            img.centerYAnchor.constraint(equalTo: bg.centerYAnchor),
            img.widthAnchor.constraint(equalToConstant: 16),
            img.heightAnchor.constraint(equalToConstant: 16)
        ])
        return bg
    }

    private func makeRowTitle(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 15)
        l.textColor = UIColor(named: "OnDarkTextPrimary")!
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func makeSectionHeader(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(named: "OnDarkTextCaption")!
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func makeCard() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(named: "ElevatedSurface")!
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor(named: "BorderHairline")!.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    private func makeDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(named: "DividerRow")!
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    // MARK: - Actions

    @objc private func rowHighlight(_ s: UIControl) { UIView.animate(withDuration: 0.1) { s.alpha = 0.6 } }
    @objc private func rowUnhighlight(_ s: UIControl) { UIView.animate(withDuration: 0.2) { s.alpha = 1 } }

    private func showAudioQualityPicker() {
        let alert = UIAlertController(title: "Audio Keyfiyyəti", message: nil, preferredStyle: .actionSheet)
        ["Yüksək (Lossless)", "Orta", "Aşağı"].forEach { q in
            alert.addAction(UIAlertAction(title: q, style: .default))
        }
        alert.addAction(UIAlertAction(title: "Ləğv et", style: .cancel))
        present(alert, animated: true)
    }

    private func confirmClearCache() {
        let alert = UIAlertController(title: "Keşi Təmizlə", message: "1.2 GB silinəcək. Əminsiniz?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ləğv et", style: .cancel))
        alert.addAction(UIAlertAction(title: "Təmizlə", style: .destructive))
        present(alert, animated: true)
    }
}

