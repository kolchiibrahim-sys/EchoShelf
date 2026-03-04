//
//  LibraryCoordinator.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 05.03.26.
//

import UIKit

final class LibraryCoordinator: Coordinator {

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vm = LibraryViewModel()
        let vc = LibraryViewController(viewModel: vm)
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    // MARK: - Navigation

    func openBook(_ item: LibraryItem) {
        guard let url = item.localURL else { return }

        // EbookReaderViewController-i local URL ilə aç
        let vc = LibraryReaderViewController(item: item, localURL: url)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func confirmDelete(_ item: LibraryItem,
                       from vc: UIViewController,
                       onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Remove from Library?",
            message: "\"\(item.title)\" will be deleted from your device.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { _ in
            onConfirm()
        })
        vc.present(alert, animated: true)
    }
}
