//
//  EbookReaderViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 02.03.26.
//
import UIKit
import PDFKit
import Kingfisher
final class EbookReaderViewController: UIViewController {

    // MARK: - ViewModel

    private let viewModel: EbookReaderViewModel

    // MARK: - UI

    private var pdfView: PDFView!

    // Loading
    private let loadingContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "AppBackground")
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.layer.shadowColor = UIColor.black.cgColor
        iv.layer.shadowOpacity = 0.5
        iv.layer.shadowRadius = 20
        iv.layer.shadowOffset = CGSize(width: 0, height: 10)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let loadingTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 17, weight: .semibold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let loadingAuthorLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14)
        lbl.textColor = UIColor.white.withAlphaComponent(0.5)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let progressBar: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.progressTintColor = .systemPurple
        pv.trackTintColor = UIColor.white.withAlphaComponent(0.1)
        pv.layer.cornerRadius = 3
        pv.clipsToBounds = true
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()

    private let progressLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Preparing your book..."
        lbl.font = .systemFont(ofSize: 13)
        lbl.textColor = UIColor.white.withAlphaComponent(0.5)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // Error
    private let errorContainer: UIView = {
        let v = UIView()
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let errorIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "exclamationmark.circle"))
        iv.tintColor = UIColor.white.withAlphaComponent(0.3)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
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

    private let retryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Try Again"
        config.baseBackgroundColor = .systemPurple
        config.cornerStyle = .capsule
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // Page counter (PDF açılanda görünür)
    private let pageLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = UIColor.white.withAlphaComponent(0.4)
        lbl.textAlignment = .center
        lbl.isHidden = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // MARK: - Init

    init(ebook: Ebook) {
        self.viewModel = EbookReaderViewModel(ebook: ebook)
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
        setupPageLabel()
        bindViewModel()
        viewModel.loadDocument()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        viewModel.cancelDownload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

// MARK: - Binding

private extension EbookReaderViewController {

    func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }

            switch state {
            case .idle:
                break

            case .downloading(let progress):
                self.loadingContainer.isHidden = false
                self.pdfView.isHidden = true
                self.errorContainer.isHidden = true
                self.pageLabel.isHidden = true

                UIView.animate(withDuration: 0.2) {
                    self.progressBar.setProgress(progress, animated: true)
                }

                if progress > 0 {
                    let pct = Int(progress * 100)
                    self.progressLabel.text = "Downloading... \(pct)%"
                }

            case .loaded(let document):
                self.pdfView.document = document
                self.pdfView.scaleFactor = self.viewModel.scaleFactor

                UIView.animate(withDuration: 0.4) {
                    self.loadingContainer.alpha = 0
                } completion: { _ in
                    self.loadingContainer.isHidden = true
                    self.loadingContainer.alpha = 1
                    self.pdfView.isHidden = false
                    self.pageLabel.isHidden = false
                }

            case .error(let message):
                self.loadingContainer.isHidden = true
                self.pdfView.isHidden = true
                self.errorContainer.isHidden = false
                self.errorLabel.text = message
            }
        }

        viewModel.onProgressChanged = { [weak self] current, total in
            guard let self, total > 0 else { return }
            self.pageLabel.text = "\(current + 1) / \(total)"
        }
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
            UIAction(title: "Larger", image: UIImage(systemName: "textformat.size.larger")) { [weak self] _ in
                guard let self else { return }
                self.viewModel.increaseScale()
                self.pdfView.scaleFactor = self.viewModel.scaleFactor
            },
            UIAction(title: "Smaller", image: UIImage(systemName: "textformat.size.smaller")) { [weak self] _ in
                guard let self else { return }
                self.viewModel.decreaseScale()
                self.pdfView.scaleFactor = self.viewModel.scaleFactor
            },
            UIAction(title: "Reset", image: UIImage(systemName: "arrow.counterclockwise")) { [weak self] _ in
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
        pdfView.isHidden = true
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
        view.addSubview(loadingContainer)

        if let coverURL = viewModel.ebook.coverURL {
            coverImageView.kf.setImage(with: coverURL)
        }
        loadingTitleLabel.text  = viewModel.ebook.title
        loadingAuthorLabel.text = viewModel.ebook.authorName

        loadingContainer.addSubview(coverImageView)
        loadingContainer.addSubview(loadingTitleLabel)
        loadingContainer.addSubview(loadingAuthorLabel)
        loadingContainer.addSubview(progressBar)
        loadingContainer.addSubview(progressLabel)

        NSLayoutConstraint.activate([
            loadingContainer.topAnchor.constraint(equalTo: view.topAnchor),
            loadingContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            coverImageView.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),
            coverImageView.centerYAnchor.constraint(equalTo: loadingContainer.centerYAnchor, constant: -80),
            coverImageView.widthAnchor.constraint(equalToConstant: 140),
            coverImageView.heightAnchor.constraint(equalToConstant: 200),

            loadingTitleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 24),
            loadingTitleLabel.leadingAnchor.constraint(equalTo: loadingContainer.leadingAnchor, constant: 40),
            loadingTitleLabel.trailingAnchor.constraint(equalTo: loadingContainer.trailingAnchor, constant: -40),

            loadingAuthorLabel.topAnchor.constraint(equalTo: loadingTitleLabel.bottomAnchor, constant: 6),
            loadingAuthorLabel.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),

            progressBar.topAnchor.constraint(equalTo: loadingAuthorLabel.bottomAnchor, constant: 28),
            progressBar.leadingAnchor.constraint(equalTo: loadingContainer.leadingAnchor, constant: 40),
            progressBar.trailingAnchor.constraint(equalTo: loadingContainer.trailingAnchor, constant: -40),
            progressBar.heightAnchor.constraint(equalToConstant: 6),

            progressLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 12),
            progressLabel.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor)
        ])
    }

    func setupErrorView() {
        errorContainer.addSubview(errorIcon)
        errorContainer.addSubview(errorLabel)
        errorContainer.addSubview(retryButton)
        view.addSubview(errorContainer)

        NSLayoutConstraint.activate([
            errorContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            errorContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            errorIcon.topAnchor.constraint(equalTo: errorContainer.topAnchor),
            errorIcon.centerXAnchor.constraint(equalTo: errorContainer.centerXAnchor),
            errorIcon.widthAnchor.constraint(equalToConstant: 52),
            errorIcon.heightAnchor.constraint(equalToConstant: 52),

            errorLabel.topAnchor.constraint(equalTo: errorIcon.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: errorContainer.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: errorContainer.trailingAnchor),

            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            retryButton.centerXAnchor.constraint(equalTo: errorContainer.centerXAnchor),
            retryButton.bottomAnchor.constraint(equalTo: errorContainer.bottomAnchor)
        ])

        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
    }

    func setupPageLabel() {
        view.addSubview(pageLabel)
        NSLayoutConstraint.activate([
            pageLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            pageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - Actions

private extension EbookReaderViewController {

    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func retryTapped() {
        errorContainer.isHidden = true
        viewModel.loadDocument()
    }

    @objc func pageChanged() {
        guard let page = pdfView.currentPage,
              let document = pdfView.document else { return }
        viewModel.updateCurrentPage(document.index(for: page))
    }
}
