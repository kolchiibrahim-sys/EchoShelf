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
    private var currentIndex: Int = 0

    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = UIColor(named: "PrimaryGradientStart")
        pc.pageIndicatorTintColor = UIColor(named: "OnDarkChevron")
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    private lazy var skipButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Skip"
        config.baseForegroundColor = UIColor(named: "OnDarkTextSecondary")
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            return a
        }
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var primaryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor(named: "PrimaryGradientStart")
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            return a
        }
        config.cornerStyle = .capsule
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var secondaryButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = UIColor(named: "OnDarkTextSecondary")
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            return a
        }
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPages()
        setupPageViewController()
        setupUI()
        setupActions()
        updateButtons(for: 0)
    }

    private func setupPages() {
        pages = viewModel.pages.map { page in
            OnboardingPageViewController(page: page)
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

        pageViewController.setViewControllers([pages[0]], direction: .forward, animated: false)
    }

    private func setupUI() {
        view.addSubview(pageControl)
        view.addSubview(skipButton)
        view.addSubview(primaryButton)
        view.addSubview(secondaryButton)

        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0

        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            secondaryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            secondaryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            secondaryButton.heightAnchor.constraint(equalToConstant: 44),

            primaryButton.bottomAnchor.constraint(equalTo: secondaryButton.topAnchor, constant: -8),
            primaryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            primaryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            primaryButton.heightAnchor.constraint(equalToConstant: 58),

            pageControl.bottomAnchor.constraint(equalTo: primaryButton.topAnchor, constant: -16),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupActions() {
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(secondaryTapped), for: .touchUpInside)
    }

    private func updateButtons(for index: Int) {
        let page = viewModel.pages[index]

        var primaryConfig = primaryButton.configuration
        primaryConfig?.title = page.primaryButtonTitle
        primaryButton.configuration = primaryConfig

        if let secondary = page.secondaryButtonTitle {
            var secondaryConfig = secondaryButton.configuration
            secondaryConfig?.title = secondary
            secondaryButton.configuration = secondaryConfig
            secondaryButton.isHidden = false
        } else {
            secondaryButton.isHidden = true
        }

        skipButton.isHidden = index == pages.count - 1
    }

    private func goToPage(_ index: Int) {
        guard index < pages.count else { return }
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true)
        currentIndex = index
        pageControl.currentPage = index
        updateButtons(for: index)
    }

    @objc private func skipTapped() {
        onFinish?()
    }

    @objc private func primaryTapped() {
        if currentIndex == pages.count - 1 {
            onFinish?()
        } else {
            goToPage(currentIndex + 1)
        }
    }

    @objc private func secondaryTapped() {
        if currentIndex == pages.count - 1 {
            onSignIn?()
        } else {
            goToPage(currentIndex + 1)
        }
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let current = viewController as? OnboardingPageViewController,
              let index = pages.firstIndex(of: current),
              index > 0 else { return nil }
        return pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let current = viewController as? OnboardingPageViewController,
              let index = pages.firstIndex(of: current),
              index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let current = pageViewController.viewControllers?.first as? OnboardingPageViewController,
              let index = pages.firstIndex(of: current) else { return }
        currentIndex = index
        pageControl.currentPage = index
        updateButtons(for: index)
    }
}
