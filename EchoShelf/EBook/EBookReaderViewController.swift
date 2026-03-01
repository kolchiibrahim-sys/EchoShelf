//
//  EbookReaderViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 01.03.26.
//
import UIKit
import PDFKit

final class EbookReaderViewController: UIViewController {

    private let ebook: Ebook
    private let readURL: URL

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

    init(ebook: Ebook, readURL: URL) {
        self.ebook = ebook
        self.readURL = readURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupNavBar()
        setupPDFView()
        setupLoadingView()
        loadDocument()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

// MARK: - Setup

private extension EbookReaderViewController {

    func setupNavBar() {
        title = ebook.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .white

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "textformat.size"),
            style: .plain,
            target: self,
            action: #selector(fontSizeTapped)
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

        activityIndicator.startAnimating()
    }

    func loadDocument() {
        // PDF URL-dirsə birbaşa yüklə
        if readURL.pathExtension.lowercased() == "pdf" {
            loadPDF(from: readURL)
        } else {
            // EPUB və ya digər — Open Library web reader-ə yönləndir
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.loadingView.isHidden = true
                self.openInBrowser()
            }
        }
    }

    func loadPDF(from url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let document = PDFDocument(url: url) {
                DispatchQueue.main.async {
                    self.pdfView.document = document
                    UIView.animate(withDuration: 0.3) {
                        self.loadingView.alpha = 0
                    } completion: { _ in
                        self.loadingView.isHidden = true
                        self.activityIndicator.stopAnimating()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.loadingView.isHidden = true
                    self.openInBrowser()
                }
            }
        }
    }

    func openInBrowser() {
        UIApplication.shared.open(readURL)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Actions

private extension EbookReaderViewController {

    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func fontSizeTapped() {
        guard let currentScale = pdfView.scaleFactor as CGFloat? else { return }
        let newScale = currentScale < 2.0 ? currentScale + 0.25 : 1.0
        pdfView.scaleFactor = newScale
    }
}
