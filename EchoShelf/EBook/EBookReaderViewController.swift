//
//  EbookReaderViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 01.03.26.
//
import UIKit
import PDFKit

final class EbookReaderViewController: UIViewController {

    // MARK: - ViewModel

    private let viewModel: EbookReaderViewModel

    // MARK: - UI

    private var pdfView: PDFView!

    private let loadingView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "AppBackground")
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .systemPurple
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    private let loadingLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Loading book..."
        lbl.font = .systemFont(ofSize: 14)
        lbl.textColor = UIColor.white.withAlphaComponent(0.6)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let errorView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    private let errorLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15)
        lbl.textColor = UIColor.white.withAlphaComponent(0.6)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let progressLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = UIColor.white.withAlphaComponent(0.5)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // MARK: - Init

    init(ebook: Ebook, readURL: URL) {
        self.viewModel = EbookReaderViewModel(ebook: ebook, readURL: readURL)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupNavBar()
        setupPDFView()
        setupLoadingView()
        setupErrorView()
        setupProgressLabel()
        bindViewModel()
        viewModel.loadDocument()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

// MARK: - Bindings

private extension EbookReaderViewController {

    func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }
            switch state {
            case .idle:
                break

            case .loading:
                self.showLoading(true)

            case .loaded(let document):
                self.showLoading(false)
                self.pdfView.document = document
                self.pdfView.scaleFactor = self.viewModel.scaleFactor

            case .redirecting(let url):
                self.showLoading(false)
                UIApplication.shared.open(url)
                self.navigationController?.popViewController(animated: true)

            case .error(let message):
                self.showLoading(false)
                self.showError(message)
            }
        }

        viewModel.onProgressChanged = { [weak self] current, total in
            guard let self, total > 0 else { return }
            self.progressLabel.text = "Page \(current + 1) of \(total)"
        }
    }

    func showLoading(_ show: Bool) {
        loadingView.isHidden = !show
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    func showError(_ message: String) {
        errorLabel.text = message
        errorView.isHidden = false
    }
}

// MARK: - Setup

private extension EbookReaderViewController {

    func setupNavBar() {
        title = viewModel.ebook.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .white

        let fontMenu = UIMenu(title: "Text Size", children: [
            UIAction(title: "Increase", image: UIImage(systemName: "textformat.size.larger")) { [weak self] _ in
                self?.viewModel.increaseScale()
                self?.applyScale()
            },
            UIAction(title: "Decrease", image: UIImage(systemName: "textformat.size.smaller")) { [weak self] _ in
                self?.viewModel.decreaseScale()
                self?.applyScale()
            },
            UIAction(title: "Reset", image: UIImage(systemName: "arrow.counterclockwise")) { [weak self] _ in
                self?.viewModel.resetScale()
                self?.applyScale()
            }
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "textformat.size"),
            menu: fontMenu
        )
        navigationItem.rightBarButtonItem?.tintColor = .white

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "AppBackground")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    func setupPDFView() {
        pdfView = PDFView(frame: .zero)
        pdfView.backgroundColor = UIColor(named: "AppBackground") ?? .black
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.pageShadowsEnabled = false
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

    func setupLoadingView() {
        view.addSubview(loadingView)
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(loadingLabel)

        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor),

            loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16),
            loadingLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor)
        ])
    }

    func setupErrorView() {
        let icon = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
        icon.tintColor = UIColor.white.withAlphaComponent(0.3)
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        errorView.addSubview(icon)
        errorView.addSubview(errorLabel)
        view.addSubview(errorView)

        NSLayoutConstraint.activate([
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            icon.topAnchor.constraint(equalTo: errorView.topAnchor),
            icon.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 48),
            icon.heightAnchor.constraint(equalToConstant: 48),

            errorLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: errorView.bottomAnchor)
        ])
    }

    func setupProgressLabel() {
        view.addSubview(progressLabel)
        NSLayoutConstraint.activate([
            progressLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func applyScale() {
        pdfView.scaleFactor = viewModel.scaleFactor
    }
}

// MARK: - Actions

private extension EbookReaderViewController {

    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func pageChanged() {
        guard let page = pdfView.currentPage,
              let document = pdfView.document else { return }
        let index = document.index(for: page)
        viewModel.updateCurrentPage(index)
    }
}
