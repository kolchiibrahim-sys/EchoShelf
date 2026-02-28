import UIKit

final class HomeSectionHeaderView: UICollectionReusableView {

    static let identifier = "HomeSectionHeaderView"

    var onViewAll: (() -> Void)?

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let actionButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("View all", for: .normal)
        b.setTitleColor(.systemPurple, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(actionButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])

        actionButton.addTarget(self, action: #selector(viewAllTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(_ title: String, showViewAll: Bool = true) {
        titleLabel.text = title
        actionButton.isHidden = !showViewAll
    }

    @objc private func viewAllTapped() {
        onViewAll?()
    }
}
