import UIKit

final class HomeHeaderCell: UICollectionViewCell {

    static let identifier = "HomeHeaderCell"

    private let greetingLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Good Morning,"
        lbl.textColor = UIColor.white.withAlphaComponent(0.6)
        lbl.font = .systemFont(ofSize: 13, weight: .medium)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Alex."
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let searchButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        btn.tintColor = .black
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 22
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
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
        contentView.addSubview(searchButton)

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
            nameLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 2),

            searchButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            searchButton.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 44),
            searchButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
