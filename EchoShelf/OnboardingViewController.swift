//
//  OnboardingViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 14.03.26.
//
import UIKit

final class OnboardingViewController: UIViewController {

    var onFinish: (() -> Void)?
    var onSignIn: (() -> Void)?

    private let viewModel = OnboardingViewModel()
    private var pageViewController: UIPageViewController!
    private var pages: [OnboardingPageViewController] = []

    // MARK: - UI Elements

    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = UIColor(named: "PrimaryGradientStart")
        pc.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    private let skipButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Skip"
        config.baseForegroundColor = UIColor.white.withAlphaComponent(0.6)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            return a
        }
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPages()
        setupPageViewController()
        setupUI()
        setupActions()
    }

    // MARK: - Setup

    private func setupPages() {
        pages = viewModel.pages.enumerated().map { index, page in
            let vc = OnboardingPageViewController(page: page)
            vc.onPrimaryTapped = { [weak self] in
                self?.handlePrimary(at: index)
            }
            vc.onSecondaryTapped = { [weak self] in
                self?.handleSecondary(at: index)
            }
            return vc
        }
    }

    private func setupPageViewController() {
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        pageViewController.dataSource = self
        pageViewController.delegate = self

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        pageViewController.setViewControllers(
            [pages[0]],
            direction: .forward,
            animated: false
        )
    }

    private func setupUI() {
        view.addSubview(pageControl)
        view.addSubview(skipButton)

        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupActions() {
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
    }

    // MARK: - Navigation

    private func handlePrimary(at index: Int) {
        if index == pages.count - 1 {
            onFinish?()
        } else if index == pages.count - 2 {
            goToPage(index + 1)
        } else {
            goToPage(index + 1)
        }
    }

    private func handleSecondary(at index: Int) {
        if index == pages.count - 1 {
            onSignIn?()
        } else {
            goToPage(index + 1)
        }
    }

    private func goToPage(_ index: Int) {
        guard index < pages.count else { return }
        let current = pageControl.currentPage
        let direction: UIPageViewController.NavigationDirection = index > current ? .forward : .reverse
        pageViewController.setViewControllers(
            [pages[index]],
            direction: direction,
            animated: true
        )
        pageControl.currentPage = index
        updateSkipButton(for: index)
    }

    private func updateSkipButton(for index: Int) {
        skipButton.isHidden = index == pages.count - 1
    }

    // MARK: - Actions

    @objc private func skipTapped() {
        onFinish?()
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let current = viewController as? OnboardingPageViewController,
              let index = pages.firstIndex(of: current),
              index > 0 else { return nil }
        return pages[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let current = viewController as? OnboardingPageViewController,
              let index = pages.firstIndex(of: current),
              index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let current = pageViewController.viewControllers?.first as? OnboardingPageViewController,
              let index = pages.firstIndex(of: current) else { return }
        pageControl.currentPage = index
        updateSkipButton(for: index)
    }
}
