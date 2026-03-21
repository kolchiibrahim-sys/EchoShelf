//
//  LibraryReaderViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 05.03.26.
//

import UIKit
import PDFKit

final class LibraryReaderViewController: UIViewController {
    weak var coordinator: LibraryCoordinator?
    private let viewModel: LibraryReaderViewModel
    private var pdfView: PDFView!

    private let errorContainer: UIView = {
        let v = UIView()
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let errorIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "exclamationmark.circle"))
        iv.tintColor    = UIColor.white.withAlphaComponent(0.3)
        iv.contentMode  = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let errorLabel: UILabel = {
        let lbl = UILabel()
        lbl.font          = .systemFont(ofSize: 15)
        lbl.textColor     = UIColor.white.withAlphaComponent(0.6)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let pageLabel: UILabel = {
        let lbl = UILabel()
        lbl.font          = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor     = UIColor.white.withAlphaComponent(0.4)
        lbl.textAlignment = .center
        lbl.isHidden      = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.color = UIColor.white.withAlphaComponent(0.5)
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    init(item: LibraryItem) {
        self.viewModel = LibraryReaderViewModel(item: item)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupNavBar()
        setupPDFView()
        setupErrorView()
        setupPageLabel()
        setupLoadingIndicator()
        bindViewModel()
        viewModel.loadDocument()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension LibraryReaderViewController {

    func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }

            switch state {
            case .loading:
                self.loadingIndicator.startAnimating()
                self.pdfView.isHidden        = true
                self.errorContainer.isHidden = true

            case .ready(let document):
                self.loadingIndicator.stopAnimating()
                self.errorContainer.isHidden = true

                self.pdfView.document    = document
                self.pdfView.scaleFactor = self.viewModel.scaleFactor

                // Əvvəlki oxuma yerinə qayıt
                if self.viewModel.currentPage > 0,
                   let page = document.page(at: self.viewModel.currentPage) {
                    self.pdfView.go(to: page)
                }

                UIView.animate(withDuration: 0.3) {
                    self.pdfView.isHidden   = false
                    self.pageLabel.isHidden = false
                }

            case .error(let message):
                self.loadingIndicator.stopAnimating()
                self.pdfView.isHidden        = true
                self.pageLabel.isHidden      = true
                self.errorContainer.isHidden = false
                self.errorLabel.text         = message
            }
        }

        viewModel.onProgressChanged = { [weak self] _, _ in
            guard let self else { return }
            self.pageLabel.text = self.viewModel.pageDisplayText
        }
    }
}

private extension LibraryReaderViewController {

    func setupNavBar() {
        title = viewModel.item.title

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain, target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .white

        let fontMenu = UIMenu(title: "Text Size", children: [
            UIAction(title: "Larger",  image: UIImage(systemName: "textformat.size.larger")) { [weak self] _ in
                guard let self else { return }
                self.viewModel.increaseScale()
                self.pdfView.scaleFactor = self.viewModel.scaleFactor
            },
            UIAction(title: "Smaller", image: UIImage(systemName: "textformat.size.smaller")) { [weak self] _ in
                guard let self else { return }
                self.viewModel.decreaseScale()
                self.pdfView.scaleFactor = self.viewModel.scaleFactor
            },
            UIAction(title: "Reset",   image: UIImage(systemName: "arrow.counterclockwise")) { [weak self] _ in
                guard let self else { return }
                self.viewModel.resetScale()
                self.pdfView.scaleFactor = self.viewModel.scaleFactor
            }
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "textformat.size"),
            menu: fontMenu
        )
        navigationItem.rightBarButtonItem?.tintColor = .white

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor     = UIColor(named: "AppBackground")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance   = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    func setupPDFView() {
        pdfView = PDFView(frame: .zero)
        pdfView.backgroundColor    = UIColor(named: "AppBackground") ?? .black
        pdfView.autoScales         = true
        pdfView.displayMode        = .singlePageContinuous
        pdfView.displayDirection   = .vertical
        pdfView.pageShadowsEnabled = false
        pdfView.isHidden           = true
        pdfView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(pdfView)
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pageChanged),
            name: .PDFViewPageChanged,
            object: pdfView
        )
    }

    func setupErrorView() {
        errorContainer.addSubview(errorIcon)
        errorContainer.addSubview(errorLabel)
        view.addSubview(errorContainer)

        NSLayoutConstraint.activate([
            errorContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            errorContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            errorIcon.topAnchor.constraint(equalTo: errorContainer.topAnchor),
            errorIcon.centerXAnchor.constraint(equalTo: errorContainer.centerXAnchor),
            errorIcon.widthAnchor.constraint(equalToConstant: 48),
            errorIcon.heightAnchor.constraint(equalToConstant: 48),

            errorLabel.topAnchor.constraint(equalTo: errorIcon.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: errorContainer.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: errorContainer.trailingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: errorContainer.bottomAnchor)
        ])
    }

    func setupPageLabel() {
        view.addSubview(pageLabel)
        NSLayoutConstraint.activate([
            pageLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            pageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        loadingIndicator.startAnimating()
    }
}

private extension LibraryReaderViewController {

    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func pageChanged() {
        guard let page     = pdfView.currentPage,
              let document = pdfView.document else { return }
        viewModel.updateCurrentPage(document.index(for: page))
    }
}
