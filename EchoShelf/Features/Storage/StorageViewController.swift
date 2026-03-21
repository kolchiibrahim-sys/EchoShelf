//
//  StorageViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 07.03.26.
//

import UIKit

final class StorageCacheViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let totalGB: Double = 128
    private let usedGB: Double = 85.5
    private let appGB: Double = 32
    private var books: [(title: String, size: String, quality: String)] = [
        ("Project Hail Mary", "842 MB", "High"),
        ("Dune: Part One", "1.2 GB", "Lossless"),
        ("The 7 Habits of Highly Effective People", "310 MB", "Standart"),
        ("The Great Gatsby", "125 MB", "Standart")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "SettingsBackground")!
        title = "Memory and Cache"
        navigationController?.navigationBar.tintColor = UIColor(named: "PrimaryAccent")!
        setupScrollView()
        buildUI()
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

    private func buildUI() {
        // Storage card
        let storageCard = makeStorageCard()
        contentView.addSubview(storageCard)
        NSLayoutConstraint.activate([
            storageCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            storageCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            storageCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        // Books header
        let booksHeader = makeSectionHeader("YÜKLƏNMIŞ KİTABLAR")
        contentView.addSubview(booksHeader)
        NSLayoutConstraint.activate([
            booksHeader.topAnchor.constraint(equalTo: storageCard.bottomAnchor, constant: 24),
            booksHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])

        // Books list
        let booksCard = makeCard()
        contentView.addSubview(booksCard)
        NSLayoutConstraint.activate([
            booksCard.topAnchor.constraint(equalTo: booksHeader.bottomAnchor, constant: 8),
            booksCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            booksCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        var prevBottom = booksCard.topAnchor
        for (i, book) in books.enumerated() {
            let row = makeBookRow(book: book, index: i)
            booksCard.addSubview(row)
            NSLayoutConstraint.activate([
                row.topAnchor.constraint(equalTo: prevBottom),
                row.leadingAnchor.constraint(equalTo: booksCard.leadingAnchor),
                row.trailingAnchor.constraint(equalTo: booksCard.trailingAnchor),
                row.heightAnchor.constraint(equalToConstant: 68)
            ])
            if i < books.count - 1 {
                let div = UIView()
                div.backgroundColor = UIColor(named: "DividerRow")!
                div.translatesAutoresizingMaskIntoConstraints = false
                booksCard.addSubview(div)
                NSLayoutConstraint.activate([
                    div.bottomAnchor.constraint(equalTo: row.bottomAnchor),
                    div.leadingAnchor.constraint(equalTo: booksCard.leadingAnchor, constant: 72),
                    div.trailingAnchor.constraint(equalTo: booksCard.trailingAnchor),
                    div.heightAnchor.constraint(equalToConstant: 0.5)
                ])
            }
            prevBottom = row.bottomAnchor
        }
        booksCard.bottomAnchor.constraint(equalTo: prevBottom).isActive = true

        // Cache footer
        let cacheView = makeCacheFooter()
        contentView.addSubview(cacheView)
        NSLayoutConstraint.activate([
            cacheView.topAnchor.constraint(equalTo: booksCard.bottomAnchor, constant: 20),
            cacheView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cacheView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cacheView.heightAnchor.constraint(equalToConstant: 72),
            cacheView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    // MARK: - Storage Card

    private func makeStorageCard() -> UIView {
        let card = makeCard()

        let sectionLabel = makeSectionHeader("CİHAZ YADDAŞI")
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false

        let totalLabel = UILabel()
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        let totalAttr = NSMutableAttributedString(
            string: "\(Int(totalGB)) GB ",
            attributes: [.font: UIFont.systemFont(ofSize: 26, weight: .bold), .foregroundColor: UIColor(named: "OnDarkTextPrimary")!]
        )
        totalAttr.append(NSAttributedString(
            string: "Toplam",
            attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor(named: "OnDarkTextTertiary")!]
        ))
        totalLabel.attributedText = totalAttr

        let freeLabel = UILabel()
        freeLabel.text = "\(String(format: "%.1f", totalGB - usedGB)) GB Boş"
        freeLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        freeLabel.textColor = UIColor(named: "PrimaryAccent")!
        freeLabel.translatesAutoresizingMaskIntoConstraints = false

        // Progress bar
        let barBg = UIView()
        barBg.backgroundColor = UIColor(named: "FillGlassStrong")!
        barBg.layer.cornerRadius = 4
        barBg.translatesAutoresizingMaskIntoConstraints = false

        let appFill = UIView()
        appFill.backgroundColor = UIColor(named: "PrimaryAccent")!
        appFill.layer.cornerRadius = 4
        appFill.translatesAutoresizingMaskIntoConstraints = false

        let otherFill = UIView()
        otherFill.backgroundColor = UIColor(named: "StorageSecondaryBar")!
        otherFill.layer.cornerRadius = 4
        otherFill.translatesAutoresizingMaskIntoConstraints = false

        // Legend
        let legendStack = makeProgressLegend()

        card.addSubview(sectionLabel)
        card.addSubview(totalLabel)
        card.addSubview(freeLabel)
        card.addSubview(barBg)
        barBg.addSubview(otherFill)
        barBg.addSubview(appFill)
        card.addSubview(legendStack)

        let otherRatio = CGFloat((usedGB - appGB) / totalGB)
        let appRatio = CGFloat(appGB / totalGB)

        NSLayoutConstraint.activate([
            sectionLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            sectionLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

            totalLabel.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 6),
            totalLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

            freeLabel.centerYAnchor.constraint(equalTo: totalLabel.centerYAnchor),
            freeLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            barBg.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 14),
            barBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            barBg.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            barBg.heightAnchor.constraint(equalToConstant: 8),

            appFill.topAnchor.constraint(equalTo: barBg.topAnchor),
            appFill.leadingAnchor.constraint(equalTo: barBg.leadingAnchor),
            appFill.bottomAnchor.constraint(equalTo: barBg.bottomAnchor),
            appFill.widthAnchor.constraint(equalTo: barBg.widthAnchor, multiplier: appRatio),

            otherFill.topAnchor.constraint(equalTo: barBg.topAnchor),
            otherFill.leadingAnchor.constraint(equalTo: appFill.trailingAnchor),
            otherFill.bottomAnchor.constraint(equalTo: barBg.bottomAnchor),
            otherFill.widthAnchor.constraint(equalTo: barBg.widthAnchor, multiplier: otherRatio),

            legendStack.topAnchor.constraint(equalTo: barBg.bottomAnchor, constant: 12),
            legendStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            legendStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }

    private func makeProgressLegend() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        let items: [(color: UIColor, label: String)] = [
            (UIColor(named: "PrimaryAccent")!, "EchoShelf (\(Int(appGB)) GB)"),
            (UIColor(named: "StorageChartOther")!, "Digər (\(String(format: "%.1f", usedGB - appGB)) GB)"),
            (UIColor(named: "StorageChartEmpty")!, "Boş (\(String(format: "%.1f", totalGB - usedGB)) GB)")
        ]
        for item in items {
            let dot = UIView()
            dot.backgroundColor = item.color
            dot.layer.cornerRadius = 4
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 8).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 8).isActive = true

            let lbl = UILabel()
            lbl.text = item.label
            lbl.font = .systemFont(ofSize: 11)
            lbl.textColor = UIColor(named: "TabTextInactive")!

            let h = UIStackView(arrangedSubviews: [dot, lbl])
            h.axis = .horizontal
            h.spacing = 5
            h.alignment = .center
            stack.addArrangedSubview(h)
        }
        return stack
    }

    // MARK: - Book Row

    private func makeBookRow(book: (title: String, size: String, quality: String), index: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let coverBg = UIView()
        coverBg.backgroundColor = UIColor(named: "FillGlassMedium")!
        coverBg.layer.cornerRadius = 6
        coverBg.translatesAutoresizingMaskIntoConstraints = false

        let coverIcon = UIImageView(image: UIImage(systemName: "book.fill"))
        coverIcon.tintColor = UIColor(named: "OnDarkChevron")!
        coverIcon.contentMode = .scaleAspectFit
        coverIcon.translatesAutoresizingMaskIntoConstraints = false

        let titleLbl = UILabel()
        titleLbl.text = book.title
        titleLbl.font = .systemFont(ofSize: 14, weight: .medium)
        titleLbl.textColor = UIColor(named: "OnDarkTextPrimary")!
        titleLbl.translatesAutoresizingMaskIntoConstraints = false

        let detailLbl = UILabel()
        detailLbl.text = "\(book.size) • \(book.quality)"
        detailLbl.font = .systemFont(ofSize: 12)
        detailLbl.textColor = UIColor(named: "OnDarkTextDetail")!
        detailLbl.translatesAutoresizingMaskIntoConstraints = false

        let deleteBtn = UIButton(type: .system)
        deleteBtn.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteBtn.tintColor = UIColor(named: "IconRed")!
        deleteBtn.translatesAutoresizingMaskIntoConstraints = false
        deleteBtn.tag = index
        deleteBtn.addTarget(self, action: #selector(deleteBook(_:)), for: .touchUpInside)

        coverBg.addSubview(coverIcon)
        container.addSubview(coverBg)
        container.addSubview(titleLbl)
        container.addSubview(detailLbl)
        container.addSubview(deleteBtn)

        NSLayoutConstraint.activate([
            coverBg.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            coverBg.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            coverBg.widthAnchor.constraint(equalToConstant: 42),
            coverBg.heightAnchor.constraint(equalToConstant: 42),

            coverIcon.centerXAnchor.constraint(equalTo: coverBg.centerXAnchor),
            coverIcon.centerYAnchor.constraint(equalTo: coverBg.centerYAnchor),
            coverIcon.widthAnchor.constraint(equalToConstant: 20),
            coverIcon.heightAnchor.constraint(equalToConstant: 20),

            titleLbl.leadingAnchor.constraint(equalTo: coverBg.trailingAnchor, constant: 12),
            titleLbl.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLbl.trailingAnchor.constraint(equalTo: deleteBtn.leadingAnchor, constant: -8),

            detailLbl.leadingAnchor.constraint(equalTo: titleLbl.leadingAnchor),
            detailLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 3),

            deleteBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            deleteBtn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            deleteBtn.widthAnchor.constraint(equalToConstant: 28),
            deleteBtn.heightAnchor.constraint(equalToConstant: 28)
        ])

        return container
    }

    // MARK: - Cache Footer

    private func makeCacheFooter() -> UIView {
        let card = makeCard()

        let cacheLabel = UILabel()
        cacheLabel.translatesAutoresizingMaskIntoConstraints = false
        let attr = NSMutableAttributedString(
            string: "MÜVƏQQƏTİ KEŞ\n",
            attributes: [.font: UIFont.systemFont(ofSize: 10, weight: .semibold), .foregroundColor: UIColor(named: "OnDarkTextCaption")!]
        )
        attr.append(NSAttributedString(
            string: "2.4 GB",
            attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold), .foregroundColor: UIColor(named: "OnDarkTextPrimary")!]
        ))
        cacheLabel.attributedText = attr
        cacheLabel.numberOfLines = 2

        let clearBtn = UIButton(type: .system)
        clearBtn.setTitle("KEŞİ TƏMİZLƏ", for: .normal)
        clearBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        clearBtn.backgroundColor = UIColor(named: "PrimaryAccent")!
        clearBtn.setTitleColor(UIColor(named: "OnDarkTextPrimary")!, for: .normal)
        clearBtn.layer.cornerRadius = 20
        clearBtn.translatesAutoresizingMaskIntoConstraints = false
        clearBtn.addTarget(self, action: #selector(clearCacheTapped), for: .touchUpInside)

        card.addSubview(cacheLabel)
        card.addSubview(clearBtn)

        NSLayoutConstraint.activate([
            cacheLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            cacheLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            clearBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            clearBtn.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            clearBtn.widthAnchor.constraint(equalToConstant: 140),
            clearBtn.heightAnchor.constraint(equalToConstant: 40)
        ])

        return card
    }

    // MARK: - Helpers

    private func makeCard() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(named: "ElevatedSurface")!
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor(named: "BorderHairline")!.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    private func makeSectionHeader(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 10, weight: .semibold)
        l.textColor = UIColor(named: "OnDarkTextCaption")!
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    // MARK: - Actions

    @objc private func deleteBook(_ sender: UIButton) {
        let idx = sender.tag
        let alert = UIAlertController(title: "Kitabı Sil", message: "\"\(books[idx].title)\" silinsin?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ləğv et", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sil", style: .destructive) { [weak self] _ in
            self?.books.remove(at: idx)
            // TODO: LibraryManager.shared.delete(id:)
        })
        present(alert, animated: true)
    }

    @objc private func clearCacheTapped() {
        let alert = UIAlertController(title: "Keşi Təmizlə", message: "2.4 GB müvəqqəti fayl silinəcək.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ləğv et", style: .cancel))
        alert.addAction(UIAlertAction(title: "Təmizlə", style: .destructive))
        present(alert, animated: true)
    }
}
