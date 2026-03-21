//
//  HomeHeaderCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import UIKit

final class HomeHeaderCell: UICollectionViewCell {

    static let identifier = "HomeHeaderCell"

    private let greetingLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.white.withAlphaComponent(0.6)
        lbl.font = .systemFont(ofSize: 13, weight: .medium)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
        v.layer.cornerRadius = 24
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let avatarIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person.fill"))
        iv.tintColor = .systemOrange
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    

    private func setupUI() {
        contentView.addSubview(avatarView)
        avatarView.addSubview(avatarIcon)
        contentView.addSubview(greetingLabel)
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 48),
            avatarView.heightAnchor.constraint(equalToConstant: 48),

            avatarIcon.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarIcon.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),

            greetingLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 14),
            greetingLabel.topAnchor.constraint(equalTo: avatarView.topAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 2)
        ])
    }

    

    func configure() {
        greetingLabel.text = Self.timeBasedGreeting()
        nameLabel.text = Self.userName()
    }

    

    static func timeBasedGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good Morning,"
        case 12..<17: return "Good Afternoon,"
        case 17..<21: return "Good Evening,"
        default:      return "Good Night,"
        }
    }

    static func userName() -> String {
        let name = UserDefaults.standard.string(forKey: "user_name") ?? "Alex"
        // "Ibrahim Kolchi" → "Ibrahim" — yalnız first name göstər
        let firstName = name.components(separatedBy: " ").first ?? name
        return "\(firstName)."
    }
}
