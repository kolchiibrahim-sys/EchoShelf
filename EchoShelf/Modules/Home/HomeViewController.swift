//
//  Home.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import UIKit

final class HomeViewController: UIViewController {

    private let viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Home"

        bindViewModel()
        viewModel.fetchAudiobooks()
    }

    private func bindViewModel() {

        viewModel.onDataUpdated = { [weak self] in
            print("Loaded books count:", self?.viewModel.audiobooks.count ?? 0)
        }

        viewModel.onError = { error in
            print(error)
        }
    }
}
