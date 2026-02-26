//
//  DetailLabels.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 26.02.26.
//
import UIKit

final class DetailSectionTitle: UILabel {

    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        font = .systemFont(ofSize: 20, weight: .bold)
        textColor = .white
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) { fatalError() }
}

final class DetailBodyLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        numberOfLines = 0
        textColor = UIColor(white: 1, alpha: 0.7)
        font = .systemFont(ofSize: 15)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) { fatalError() }
}
